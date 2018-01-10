#
# BasicFeatures.ps1
#
Import-Module ..\WinGUI -Force

$WWGUIControlEnumTypeTypeDefinition =
@"
public enum WWGUIControlEnumType
{
    StartsHere,
    Browser,
    Button,
    Caption,
    Checkbox,
    CheckListBox,
    UpDown,
    Dropdown,
    Groupbox,
    Header,
    Help,
    Image,
    Label,
    Link,
    ListBox,
    Listview,
    Menu,
    ProgressBar,
    RadioButton,
    RichTextBox,
    TabControl,
    Textbox
}
"@
if(-not ([System.Management.Automation.PSTypeName] "WWGUIControlEnumType").Type)
{
    Add-Type -TypeDefinition $WWGUIControlEnumTypeTypeDefinition
}

Function GetContents
{
    param(
        [System.Windows.Forms.TabPage]$page,
        [WWGUIControlEnumType]$ControlType
    )

    $subTabCtrl = Get-UIControl "tabcontrol" "Description","Examples" 0 "" @{Alignment="Left";PageColor="white";PageBackColor="White,White"}
    $page.Controls.Add($subTabCtrl)

	$ctrl = Get-UIControl "richtextbox" $null 0 "view" @{File="C:\Program Files\WindowsPowerShell\Modules\wwGUI\Examples\$ControlType.rtf";Dock="Fill"}
    $subTabCtrl.TabPages["Description"].Controls.Add($ctrl)

    $global:vpos = 10;$global:hpos =10
    switch($ControlType)
    {
        StartsHere {
            # Default
            $ctrls = Get-UIControl Caption "Default :" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrl = Get-UIControl "button" "Hello World!"
            $ctrl.Add_Click({
                $w= Get-UIWinForm "Hello World!"
                $w.ShowDialog() | Out-Null
            })
            $subTabCtrl.TabPages["Examples"].Controls.Add($ctrl)

			# Code
            $ctrls = Get-UIControl label "`$ctrl = Get-UIControl 'button' 'hello';`$ctrl.Add_Click({`$w = Get-UIWinForm 'Hello World';`$w.ShowDialog() | Out-Null"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "Browser" {
            $ctrl = Get-UIControl "browser" "http://bing.com"
            $subTabCtrl.TabPages["Examples"].Controls.Add($ctrl)
        }
        "Button" {
            # Default
            $ctrls = Get-UIControl Caption "Default :" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrl = Get-UIControl "button" "hello"
            $subTabCtrl.TabPages["Examples"].Controls.Add($ctrl)

			# Code
            $ctrls = Get-UIControl label "Get-UIControl 'button' 'hello'"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "Caption" {
            $ctrls = Get-UIControl Caption "Status:" 0 "" @{Help="Hello"}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "Checkbox" {
            # Default
            $ctrls = Get-UIControl Caption "Default :" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrls = Get-UIControl checkbox $true 0 "edit" @{Text="blah";Appearance="Button";Opposite=1}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			# Code
            $ctrls = Get-UIControl label "Get-UIControl checkbox $true 0 'edit' @{Text='blah';Appearance='Button';Opposite=1}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "CheckListBox" {
            # Default
            $ctrls = Get-UIControl Caption "Default :" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrls = Get-UIControl checklistbox "bbb","ccc" 0 "edit" @{Elements="aaa,bbb,ccc"}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			# Code
            $ctrls = Get-UIControl label "Get-UIControl checklistbox 'bbb','ccc' 0 'edit' @{Elements='aaa,bbb,ccc'}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "UpDown" {
            # Default
            $ctrls = Get-UIControl Caption "Default :" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			$ctrls = Get-UIControl UpDown "5 minutes" 0 "edit" @{Name="dudFilter";Text="4 hours,2 hours,1 hours,30 minutes,15 minutes,5 minutes"}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			# Code
            $ctrls = Get-UIControl label "Get-UIControl UpDown '5 minutes' 0 'edit' @{Name='dudFilter';Text='4 hours,2 hours,1 hours,30 minutes,15 minutes,5 minutes'}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "Dropdown" {
            # Default
            $ctrls = Get-UIControl Caption "Default :" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrls = Get-UIControl dropdown "GRS" 300 "edit" @{Name="ddlType";Elements="LRS|Locally Redundant,ZRS|Zone Redundant,GRS|Geo-Redundant,RAGRS|Read-Access Geo-Redundant"}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			# Code
            $ctrls = Get-UIControl label "Get-UIControl dropdown 'GRS' 300 'edit' @{Name='ddlType';Elements='LRS|Locally Redundant,ZRS|Zone Redundant,GRS|Geo-Redundant,RAGRS|Read-Access Geo-Redundant'}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "Groupbox" {
			# Default
            $grp = Get-UIControl GroupBox "My Asset" 400,200

            $global:vpos = 20
            $ctrls = Get-UIControl Caption "Text inside the box" 150
            $grp.Controls.AddRange($ctrls)

            $subTabCtrl.TabPages["Examples"].Controls.AddRange($grp)
        }
        "Header" {
			# Default
            $ctrls = Get-UIControl header "Settings" 600 "" @{Help="Additional help can be provided here"}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "Help" {
			# Default
            $ctrls = Get-UIControl help "This is read-only field because the location for the disk must be on the same storage account where the VM is"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "Image" {
        	$ctrls = Get-UIControl "image" null 16,16 "" @{IconElements="c:\admin\wwazure\assets\azure.png"}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "Label" {
            $ctrls = Get-UIControl label "test"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "Link" {
            $ctrls = Get-UIControl link https://github.com/Azure/azure-powershell/releases/latest
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "ListBox" {
            # Default
            $ctrls = Get-UIControl Caption "Default :" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrls = Get-UIControl listbox $null 0 "edit" @{Elements="aaaa,bbbb,cccc"}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

        }
        "Listview" {
            $col = Get-Process | select -first 10 | select Name, SI, Id, CPU
            $ctrls = Get-UIControl listview $col
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "Menu" {
			$ctrls = Get-UIControl menu $null 0 "" @{Elements="<Layouts><Layout ID='Dashboard' Help='dddd'/><Layout ID='Email'><Sublayout ID='Outbound'/><Sublayout ID='Inbound'/></Layout></Layouts>"}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "ProgressBar" {
            # Default
            $ctrls = Get-UIControl Caption "Default :"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrls = Get-UIControl progressbar 12,100 500
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "RadioButton" {
            # Default
            $ctrls = Get-UIControl Caption "Default :" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

		    $ctrls = Get-UIControl radiobutton "New" 0 "edit" @{Text="New,Existing"}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			# Code
            $ctrls = Get-UIControl label "Get-UIControl radiobutton "" 0 'edit' @{Text='New,Existing'}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            # Normal Appearance
            $ctrls = Get-UIControl Caption "Default :" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

		    $ctrls = Get-UIControl radiobutton "Choice2" 0 "edit" @{Text="Choice1,Choice2,Choice3";NormalAppearance=1}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			# Code
            $ctrls = Get-UIControl label "Get-UIControl radiobutton "" 0 'edit' @{Text='Choice1,Choice2,Choice3';NormalAppearance=1}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            # Help & Tooltip
            $ctrls = Get-UIControl Caption "Help & Tooltip:" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

		    $ctrls = Get-UIControl radiobutton "New" 0 "edit" @{Text="Selection A,Selection B,Selection C";Help="this is help";Tooltip="tooltip1,tooltip2,tooltip3"}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrls = Get-UIControl label "Get-UIControl radiobutton "" 0 'edit' @{Text='Choice1,Choice2,Choice3';NormalAppearance=1}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "RichTextBox" {
$tmp =
"{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang1033{\fonttbl{\f0\fnil\fcharset0 Calibri;}}
{\colortbl ;\red255\green0\blue0;}
{\*\generator Riched20 10.0.10586}\viewkind4\uc1
\pard\sa200\sl276\slmult1\cf1\f0\fs22\lang9 Hello\cf0  \b World\b0\par
}"
            # Default
            $ctrls = Get-UIControl Caption "Regular RichTextBox:"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

        	$ctrls = Get-UIControl "richtextbox" $tmp 500,280
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            # Code
            $ctrls = Get-UIControl label "Get-UIControl RichTextBox $var1 500,280"" 0 'edit'"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

        }
        "TabControl" {
            $ctrls = Get-UIControl Caption "Tabs at bottom :"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $tabctrl = Get-UIControl "tabcontrol" "Tab1","Tab2","Tab3" 0 "" @{Alignment="Bottom";PageBackColor="Yellow,Brown,Green";Help="help1,help2,help3"}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($tabCtrl)

            $ctrls = Get-UIControl label "Get-UIControl TabControl "" 0 '' @{Alignment='Bottom'}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        "Textbox" {
			# Default
            $ctrls = Get-UIControl Caption "Default :" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrls = Get-UIControl Textbox "" 0 "edit"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            # code
            $ctrls = Get-UIControl label "Get-UIControl Textbox "" 0 'edit'"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            # Password
            $ctrls = Get-UIControl Caption "Password:" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrls = Get-UIControl Textbox "" 0 "edit" @{Password=1}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			# Code
            $ctrls = Get-UIControl label "Get-UIControl Textbox "" 0 'edit' @{Password=1}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            # Uppercase/Lowercase conversion
            $ctrls = Get-UIControl Caption "Uppercase/Lowercase :" 0 "" @{NoNewLine=1}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			# Code
            $ctrls = Get-UIControl Textbox "" 0 "edit" @{CharacterCasing="Upper";NoNewLine=1}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			# Lower
            $ctrls = Get-UIControl Textbox "" 0 "edit" @{CharacterCasing="Lower"}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			# Code
            $ctrls = Get-UIControl label "Get-UIControl Textbox "" 0 'edit' @{CharacterCasing='Lower'}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            # Number
            $ctrls = Get-UIControl Caption "Number Only w/ right align:" 150,35
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrls = Get-UIControl Textbox "" -100 "edit" @{Number=1}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrls = Get-UIControl label "Get-UIControl Textbox "" -100 'edit' @{Number=1}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            # MaxLength
            $ctrls = Get-UIControl Caption "Maxlength 3:" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrls = Get-UIControl Textbox "" 0 "edit" @{MaxLength=3}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			# Code
            $ctrls = Get-UIControl label "Get-UIControl Textbox "" 0 'edit' @{MaxLength=3}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            # Copy
            $ctrls = Get-UIControl Caption "Text w/ copy feature:" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrls = Get-UIControl Textbox "" 200 "edit" @{Copy=1}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			# Coee
            $ctrls = Get-UIControl label "Get-UIControl Textbox "" 200 'edit' @{Copy=1}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            # Open Picker
            $ctrls = Get-UIControl Caption "Open Picker:" 150
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

            $ctrls = Get-UIControl Textbox "" 0 "edit" @{OpenPicker="Select a text file,Text Files (*.txt)|*.txt, c:\"}
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)

			# Code
            $ctrls = Get-UIControl label "Get-UIControl Textbox "" 0 'edit' @{OpenPicker='Select a text file,Text Files (*.txt)|*.txt, c:\'}"
            $subTabCtrl.TabPages["Examples"].Controls.AddRange($ctrls)
        }
        default {
            Get-UIMessageBox "Control Type is not defined"
        }
    }
}

#============== Main Routine =====================
$form2 = Get-UIWinForm "WWGUI Module - Basic Features Demo" "" "OK","Close" 1024 768 -canResize:$true

$tabCtrl = Get-UIControl "tabcontrol" $([Enum]::GetNames([WWGUIControlEnumType]))
$form2.Controls.AddRange($tabCtrl)

# Add contents
[Enum]::GetValues([WWGUIControlEnumType]) | % {
	GetContents $tabCtrl.TabPages["$($_.ToString())"] $_
}

$form2.ShowDialog() | Out-Null

