<#
Disclaimer:
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.
 
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
 
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code,
provided that you agree:
       (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
       (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
       (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
 
Please note: None of the conditions outlined in the disclaimer above will supersede the terms and conditions contained within the Premier Customer Services Description.

12/27/2017 - Accept OtherAttributes for menu in Get-UIControl
#>

<#
    .SYNOPSIS
        Return a Windows' menuitem

    .PARAMETER Text
        Specifies MenuItem's text

    .PARAMETER TagValue
        Specifies a string to be stored in menuitem's tag property

    .PARAMETER ShortCut
        Specifies shortcut to launch the menuitem's action
#>
Function Get-UIMenuItem
{
    Param(
        [string]
        $Text,

        [string]
        $TagValue,

        [System.Windows.Forms.Shortcut]
        $ShortCut
    )

    if($TagValue -eq "") {$TagValue = $Text}

    $mnu = New-Object System.Windows.Forms.MenuItem
    $mnu.Text = $Text
    $mnu.Tag = $TagValue

    if($ShortCut -ne $null)
    {
        $mnu.Shortcut = $ShortCut
    }

    return $mnu
}

<#
    .SYNOPSIS
        Return a Windows form

    .PARAMETER Title
        Specifies Windows' Title

    .PARAMETER IconLocation
        Specifies the path for Windows' icon

    .PARAMETER ButtonText
        Specifies Windows' button text(s)

    .PARAMETER FormWidth
        Specifies width of the Window

    .PARAMETER FormHeight
        Specifies height of the Window

    .PARAMETER CanResize
        Specifies if Window can be resized

    .PARAMETER NoEventAdded
        Skip adding default events

    .PARAMETER Maximize
        Show Window's maximized state
#>
function Get-UIWinForm
{
    param(
        [string]$Title="Title",
        [string]$IconLocation,
        [string[]]$ButtonText,
        [int]$FormWidth=500,
        [int]$FormHeight=350,
        [switch]$canResize,
        [switch]$NoEventAdded,
        [switch]$Maximize
    )

    $form2 = New-Object System.Windows.Forms.Form
    $form2.Text = $Title
    $form2.KeyPreview = $True
    $form2.AutoValidate = "Disable"
    $form2.StartPosition = "CenterScreen"
    #$form2.AutoScroll = $true
    $form2.Add_KeyDown({if ($_.KeyCode -eq "Escape") {$this.Close()}})

    $form2.Add_Shown({
        if($this.height -lt $global:vpos)
        {
            $i=0
            While($i -lt $this.Controls.Count)
            {
                if($i -eq 0)
                {
                    $this.Controls[$i].Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Top
                    $this.Controls[$i].Top = $global:vpos
                }
                elseif($this.Controls[$i] -is [System.Windows.Forms.Button] -and $this.Controls[$i].Name -like "btn*")
                {
                    $this.Controls[$i].Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Top
                    $this.Controls[$i].Top = $global:vpos + 10
                }
                else
                {
                    $i = $this.Controls.Count
                }
                $i++
            }
            $this.AutoScroll = $true
        }
    })

    $form2.ClientSize = New-Object System.Drawing.Size($formWidth,$formHeight)

    if($Maximize)
    {
        $form2.WindowState = "Maximized"
    }

    $ep = New-Object System.Windows.Forms.ErrorProvider
    $form2.Tag = $ep

    if(-not $canResize)
    {
        $form2.FormBorderStyle = "FixedDialog"
        $form2.MaximizeBox = $false
        $form2.MinimizeBox = $false
        $form2.ShowInTaskbar = $false

        if($iconLocation -eq "")
        {
            $iconLocation = "$env:dp\Assets\Settings.ico"
        }

        if($iconLocation -ne "")
        {
            Try
            {
                if(-not [System.IO.Path]::IsPathRooted($iconLocation))
                {
                    $iconLocation = "$env:dp\Assets\$iconLocation"
                }
                $Icon = New-Object system.drawing.icon ($iconLocation)
                $form2.Icon = $Icon
            }
            catch
            {
            }
        }

        if($buttonText.Length -eq 0)
        {
            $label1 = New-Object System.Windows.Forms.Label
            $label1.AutoSize = $false
            $label1.Location = New-Object System.Drawing.Size(5,$($form2.Height-78))
            $label1.Size = New-Object System.Drawing.Size($($form2.Width-5),2)
            $label1.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
            $form2.Controls.Add($label1)

            $buttonText= "OK","Cancel"
        }
    }

    if($ButtonText.Length -gt 0)
    {
        $intBottomDelta = 65
        if(!$(IsISE)) { $intBottomDelta += 10}
        $form2.Padding= new-object System.Windows.Forms.Padding(0,0,0,$($intBottomDelta-40))

        $label1 = New-Object System.Windows.Forms.Label
        $label1.AutoSize = $false
        $label1.Location = New-Object System.Drawing.Size(5,$($form2.Height-$intBottomDelta-7))
        $label1.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom
        $label1.Size = New-Object System.Drawing.Size($($form2.Width-25),2)
        $label1.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
        $form2.Controls.Add($label1)

        $tmp = $form2.Width - (90 * $buttonText.Length)
        $tmpAccept = ""
        $i = 500
        $buttonText | ForEach-Object {
            $button1 = New-Object System.Windows.Forms.Button
            $button1.TabStop = $false
            if($_.StartsWith("<"))
            {
                $tmp2 = $_.Substring(1)
                $button1.Name = ("btn{0}" -f $tmp2.Replace(" ",""))
                $button1.Text = $tmp2
                $button1.TabStop = $false
                # left bottom position
                $button1.Location = New-Object System.Drawing.Size(5,$($form2.Height-$intBottomDelta))
                $button1.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom
            }
            else
            {
                $tmp2 = $_
                # right bottom position
                $button1.Location = New-Object System.Drawing.Size($tmp,$($form2.Height-$intBottomDelta))
                $button1.Anchor = [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom
            }
            $tmp += 90

            if($tmp2.StartsWith("^"))
            {
                $tmp2 = $_.Substring(1)
                $button1.Name = ("btn{0}" -f $tmp2.Replace(" ",""))
                $button1.Text = $tmp2
                $button1.Enabled = $false
            }
            else
            {
                $button1.Name = ("btn{0}" -f $tmp2.Replace(" ",""))
                $button1.Text = $tmp2
                if($tmpAccept -ne "Done") {$tmpAccept = $tmp2}
            }

            $button1.Size = New-Object System.Drawing.Size(75,25)

            if(-not $NoEventAdded -and $_ -eq $buttonText[-1])
            {
                $button1.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            }
            else
            {
                $button1.DialogResult = [System.Windows.Forms.DialogResult]::None
            }

            $form2.Controls.Add($button1)
            if($tmpAccept -ne "" -and $tmpAccept -ne "Done")
            {
                $form2.AcceptButton = $button1
                $tmpAccept = "Done"
            }$i++
        }
    }

    $global:vpos = 10
    $global:hpos = 22

    return $form2
}

<#
    .SYNOPSIS
        Get a window with an input box

    .PARAMETER Message
        Prompt for the input box

    .PARAMETER Title
        Sepcifies Windows Title

    .PARAMETER Width
        Specifies Windows Width

    .PARAMETER Message
        Specifies default text
#>
Function Get-UIInputBox
{
    param(
        [string]
        $Message="Please enter the value",

        [string]
        $Title="",

        [int]
        $Width=300,

        [string]
        $DefaultText
    )

    if($Width -eq 0) {$Width = 300}

    $form2 = Get-UIWinForm $Title "" "OK","Cancel" $Width 100

    $param = @{}
    if($Message.EndsWith(":"))
    {
        $param.Add("NoNewLine",1)
    }

    $widthLeft = 0

    $ctrls = Get-UIControl caption $Message 0 "" $param

    if($ctrls.PreferredWidth -ge $form2.Width)
    {
        $form2.Width = $ctrls.PreferredWidth
    }

    if($Message.EndsWith(":"))
    {
        $ctrls.Width = $ctrls.PreferredWidth
        $global:hpos = $ctrls.Left + $ctrls.Width + 5

        $widthLeft = $Width - $global:hpos - 20
    }
    else
    {
        $widthLeft = $Width - 40
    }
    $form2.Controls.AddRange($ctrls)

    $ctrls = Get-UIControl textbox $DefaultText $widthLeft "edit" @{Name="txtInput";TabIndex=0}
    $form2.Controls.AddRange($ctrls)

    $btnOK = $form2.Controls.Find("btnOK",$true)[0]
    if($btnOK -ne $null)
    {
        $btnOK.DialogResult = [System.Windows.Forms.DialogResult]::None
        $btnOK.Add_Click({
            $txtInput = $this.FindForm().Controls.Find("txtInput", $false)
            $this.FindForm().Tag = $txtInput.Text
            $this.FindForm().DialogResult = [System.Windows.Forms.DialogResult]::OK
        })
    }

    $form2.ShowDialog() | Out-Null

    if($form2.DialogResult -eq [System.Windows.Forms.DialogResult]::OK)
    {
        return $form2.tag
    }
}

<#
    .SYNOPSIS
        Return a message box

    .PARAMETER Title
        Specifies Windows' title

    .PARAMETER ButtonText
        Specifies text for buttons

    .PARAMETER IconText
        Specifies text for icons
#>
Function Get-UIMessageBox
{
    param(
        [string]
        $Message,

        [string]
        $Title = "Message",

        [string]
        $ButtonText = "OK",

        [string]
        $IconText = "Information"
    )

    $Message = $Message.Replace("\n", [System.Environment]::NewLine)

    $btn= [System.Windows.Forms.MessageBoxButtons]::OK
    switch($ButtonText)
    {
        "AbortRetyIgnore" {$btn= [System.Windows.Forms.MessageBoxButtons]::AbortRetryIgnore}
        "OKCancel" {$btn= [System.Windows.Forms.MessageBoxButtons]::OKCancel}
        "RetryCancel" {$btn= [System.Windows.Forms.MessageBoxButtons]::RetryCancel}
        "YesNo" {$btn= [System.Windows.Forms.MessageBoxButtons]::YesNo}
        "YesNoCancel" {$btn= [System.Windows.Forms.MessageBoxButtons]::YesNoCancel}
    }

    $icon= [System.Windows.Forms.MessageBoxIcon]::Information
    [System.Windows.Forms.MessageBoxIcon]::TryParse($IconText,[ref] $icon)

    $tmp = New-Object System.Windows.Forms.DialogResult
    $tmp = [System.Windows.Forms.MessageBox]::Show($Message, $Title, $btn, $icon)

    return $tmp
}

<#
    .SYNOPSIS
        Get a confirmation dialog

    .PARAMETER Message
        Specifies the prompt message

    .PARAMETER Title
        Specifies Windows' title
#>
Function Get-UIConfirmation
{
    param(
        [string]$Message = "Are you sure?",
        [string]$Title = "Confirm"
    )

    $tmp = Get-UIMessageBox $Message $Title "YesNo"

    If($tmp.count -gt 1) {$tmp = $tmp[$tmp.Count-1]}

    return ($tmp -eq [System.Windows.Forms.DialogResult]::Yes)
}

<#
    .SYNOPSIS
        Get a file open dialog

    .PARAMETER InitPath
        Specifies the initial directory

    .PARAMETER Filter
        Specifies the filtered file types

    .PARAMETER Title
        Specifies Windows Title

    .PARAMETER MultiSelect
        Specifies if multiple files can be selected and returned

    .EXAMPLE
        example
#>
function Get-UIFileOpenDialog()
{
    param(
        [string]$InitPath,
        [string]$Filter = "All files (*.*)|*.*",
        [string]$Title = "",
        [switch]$MultiSelect
    )

    $objForm = New-Object System.Windows.Forms.OpenFileDialog
    $objForm.Filter = $Filter

    $attr = [System.IO.File]::GetAttributes($InitPath)
    if($attr.HasFlag([System.IO.FileAttributes]::Directory))
    {
        $objForm.InitialDirectory = $InitPath
    }
    else
    {
        $objForm.InitialDirectory = [System.IO.Path]::GetDirectoryName($InitPath)
        $objForm.FileName = [System.IO.Path]::GetFileName($InitPath)
    }

    if($Title -ne ""){$objForm.Title = $Title}
    if($MultiSelect) {$objForm.Multiselect= $true}

    $result = $objForm.ShowDialog()
    if($result -eq "OK")
    {
        if($MultiSelect)
        {
            return $objForm.FileNames
        }
        else
        {
            return $objForm.FileName
        }
    }
}

<#
    .SYNOPSIS
        Get a file save dialog

    .PARAMETER InitPath
        Specifies the initial directory

    .PARAMETER InitFileName
        Specifies the initial filename

    .PARAMETER Filter
        Specifies the filtered file types

    .PARAMETER Title
        Specifies Windows Title

    .EXAMPLE
        example
#>
function Get-UIFileSaveDialog()
{
    param(
        [string]$InitPath,
        [string]$InitFileName,
        [string]$Filter = "All files (*.*)|*.*",
        [string]$Title = ""
    )

    $objForm = New-Object System.Windows.Forms.SaveFileDialog
    $objForm.Filter = $Filter
    $objForm.InitialDirectory = $InitPath
    $objForm.FileName = $InitFileName
    if($Title -ne ""){$objForm.Title = $Title}

    $result = $objForm.ShowDialog()
    if($result -eq "OK")
    {
        return $objForm.FileName
    }
}

<#
    .SYNOPSIS
        Get a folder selection dialog

    .PARAMETER InitPath
        Specifies the initial directory

    .PARAMETER Description
        Specifies the initial filename

    .PARAMETER DisableCreateNew
        Disallow new folder creating in the dialog

    .EXAMPLE
        example
#>
function Get-UIFolderSaveDialog()
{
    param(
        [string]$InitPath,
        [string]$Description = "Please select a folder",
        [switch]$DisableCreateNew
    )

    $objForm = New-Object System.Windows.Forms.FolderBrowserDialog
    $objForm.Description = $Description
    $objForm.SelectedPath = $InitPath

    if($DisableCreateNew)
    {
        $objForm.ShowNewFolderButton = false;   #Default is true
    }

    $result = $objForm.ShowDialog()

    if($result -eq "OK")
    {
        return $objForm.SelectedPath
    }
}

<#
    .SYNOPSIS
        Get a Windows control

    .PARAMETER ControlType
        Specifies the rendering control type

    .PARAMETER value
        Specifies current values of the control

    .PARAMETER Size
        Specifies size of the control

    .PARAMETER mode
        Specifies if it is displayed with edit mode or view mode

    .PARAMETER OtherAttributes
        Specifies other property values of the control
#>
Function Get-UIControl
{
    param(
        [string]
        $ControlType,

        [object[]]
        $value,

        [int[]]
        $size=0,

        [string]
        $mode="view",

        [hashtable]
        $OtherAttributes
    )

    if($ControlType -eq "listview" -and ($value -eq $null -or ($value[0] -is [System.Collections.IDictionary] -and $value[0].count -eq 0)))
    {
        $ControlType = "label"
        if($OtherAttributes -ne $null -and $OtherAttributes["NA"] -ne $null)
        {
            $value = $OtherAttributes["NA"]
        }
        else
        {
            $value = "N/A"
        }
        if($size.count -gt 0){$size.Clear()}
        $mode = "view"
        if($OtherAttributes -eq $null)
        {
            $OtherAttributes = @{}
        }
        $OtherAttributes.Add("BackColor","white")
    }

    $NoNewLine = $false
    $ctrl = $null
    Switch($ControlType)
    {
        "button" {
            $ctrl = New-Object System.Windows.Forms.Button
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            if($Size.Count -gt 0 -and $Size[0] -gt 0)
            {
                if($size.Length -gt 1)
                {
                    $ctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
                }
                else
                {
                    $ctrl.Size = New-Object System.Drawing.Size($size[0], 30)
                }
            }
            else
            {
                $ctrl.AutoSize = $true
                $ctrl.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
            }

            if($value[0].endswith(".png"))
            {
                $ctrl.Image = Get-ImageFromFile $("$env:dp\Assets\{0}" -f $value[0])
                $ctrl.Width = $ctrl.Image.Width
                $ctrl.Height = $ctrl.Image.Height
            }
            else
            {
                $ctrl.Text = $value[0]
            }

            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "ContextMenu" {
                            $ctrl.AccessibleName = $OtherAttributes["ContextMenu"]
                        }

                        "NoNewLine" {
                            $NoNewLine = $OtherAttributes[$key]
                            $global:hpos += $ctrl.PreferredSize.Width + 5
                        }

                        "Tooltip" {
                            Set-UITooltip $ctrl $OtherAttributes["Tooltip"]
                        }

                        ($($_ -eq "FontName" -or $_ -eq "FontSize")) {
                            $tmpFont = "Microsoft Sans Serif"
                            if($OtherAttributes["FontName"] -ne $null) { $tmpFont = $OtherAttributes["FontName"] }
                            $tmpSize = 8
                            if($OtherAttributes["FontSize"] -ne $null) { $tmpSize = [int]$OtherAttributes["FontSize"] }
                            $ctrl.Font = New-Object System.Drawing.Font($tmpFont,$tmpSize,[System.Drawing.FontStyle]::Regular);
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }
            }

            if(!$NoNewLine)
            {
                 $global:vpos += $allHeight + 35
            }
            else
            {
                $global:hpos += $ctrl.PreferredSize.Width + 5
            }
        }

        "browser" {
            $ctrl = New-Object System.Windows.Forms.WebBrowser
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            $ctrl.ScriptErrorsSuppressed = $true
            #$ctrl.AllowNavigation = $true
            $ctrl.BackColor = "gainsboro"
            $ctrl.Dock = [System.Windows.Forms.DockStyle]::Fill
            if($value -ne $null)
            {
                if(isURIWeb($value[0]))
                {
                    $ctrl.Navigate($value[0])
                }
                else
                {
                    $ctrl.DocumentText = $value[0]
                }
            }

            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }
            }
        }

        "caption" {
            $ctrl = New-Object System.Windows.Forms.Label
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            $ctrl.Font = New-Object System.Drawing.Font("arial",8,[System.Drawing.FontStyle]::Bold);
            $ctrl.AutoSize = $true
            if($value -ne $null)
            {
                $ctrl.Text = $value[0]
            }
            $ctrl.TabStop = $false
            if($size.count -gt 0 -and $size[0] -ne 0)
            {
                if($size[0] -lt 0)
                {
                    $ctrl.TextAlign = "TopRight"
                    $ctrl.AutoSize = $false
                    $size[0]= -1 * $size[0]
                    $ctrl.Width = $size[0]
                }
                else
                {
                    $ctrl.Width = $size[0]
                }

                if($size.Count -gt 1)
                {
                    $ctrl.AutoSize = $false
                    $ctrl.Height = $size[1]
                }
            }

            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "Alignment" {
                            $tmp = [System.Drawing.ContentAlignment]$($OtherAttributes["Alignment"])
                            $ctrl.TextAlign = $tmp
                        }

                        "Help" {
                            $oldhpos = $global:hpos

                            $col = @()
                            $col += $ctrl
                            $ctrl = $ctrl | Select-Object -last 1  #skip reqired control
                            if($ctrl.AutoSize)
                            {
                                $global:hpos += $ctrl.PreferredSize.Width + 5
                            }
                            else
                            {
                                $global:hpos += $size[0] + 5
                            }
                            $ctrl = Get-UIControl "help" $OtherAttributes["Help"] 0 "" @{NoNewLine=1}
                            $ctrl.Visible = $col[0].Visible
                            $col += $ctrl

                            $ctrl = $col

                            $global:hpos = $oldhpos
                        }

                        "NoNewLine" {
                            $NoNewLine = $true
                        }

                        "Required" {
                            $oldhpos = $global:hpos

                            $col = @()
                            $global:hpos -= 7
                            $req = Get-UIControl "caption" "*" 0 "" @{NoNewLine=1;forecolor="red"}
                            $col  += $req
                            $col += $ctrl

                            $ctrl = $col

                            $global:hpos = $oldhpos
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }
            }

            if($size.count -gt 0 -and $size[0] -ne 0)
            {
                $global:hpos += $size[0]
                $NoNewLine = $true
            }
            elseif(!$NoNewLine)
            {
                $tmp = $ctrl | Select-Object -First 1
                if($tmp.Visible)
                {
                    $global:vpos += 20
                }
            }
        }

        "cascading" {
            if($OtherAttributes["Elements"] -ne $null)
            {
                $col = @()
                if($OtherAttributes["Style"] -eq "Treeview")
                {
                    $sctrl = New-Object System.Windows.Forms.Treeview
                    $sctrl.Autosize = $true
                    if($size.Length -eq 2)
                    {
                        $sctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
                    }
                    $sctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)

                    $OtherAttributes["Elements"] | ForEach-Object {
                        $parentNode = Add-Node $sctrl $_.Parent
                        if($_.Child -ne "")
                        {
                            $_.Child.Split(",") | ForEach-Object {
                                Add-Node $parentNode $_ | Out-Null
                            }
                        }
                    }
                }
                elseif($OtherAttributes["Style"] -eq "ParentRadio")
                {
                    #radio
                    $sctrl = New-Object System.Windows.Forms.Panel
                    $sctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
                    $sctrl.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
                    $sctrl.AutoSize = $true
                    $hpos = 0
                    $iniChild = ""
                    $OtherAttributes["Elements"] | ForEach-Object {
                        $sctrl_chd = New-Object System.Windows.Forms.RadioButton
                        $sctrl_chd.Location = New-Object System.Drawing.Point($hpos, 0)
                        $sctrl_chd.AutoSize = $true
                        $sctrl_chd.Text = $_.parent
                        $sctrl_chd.Tag = $_.child
                        if($OtherAttributes["NormalAppearance"] -eq $null)
                        {
                            $sctrl_chd.Appearance = [System.Windows.Forms.Appearance]::Button
                            $sctrl_chd.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                        }

                        if($value.Count -gt 0)
                        {
                            if($value[0].GetType().Name -eq "Boolean")
                            {
                                if($_.parent -eq "On" -and $value[0])
                                {
                                    $sctrl_chd.checked = $true
                                    $sctrl.tag = "On"
                                }
                                elseif($_.parent -eq "Off" -and -not $value[0])
                                {
                                    $sctrl_chd.checked = $true
                                    $sctrl.tag = "Off"
                                }
                            }
                            elseif($_.parent -eq $value[0])
                            {
                                $sctrl_chd.checked = $true
                                $sctrl.tag = $value[0]
                            }
                        }
                        elseif($_ -eq $OtherAttributes["Elements"][0])
                        {
                            $sctrl.tag = $OtherAttributes["Elements"][0]
                        }

                        if($sctrl_chd.checked)
                        {
                            $iniChild = $_.child
                        }

                        if($mode -eq "view")
                        {
                            $sctrl_chd.Enabled = $false
                        }

                        $sctrl_chd.Add_CheckedChanged({
                            $idx = $this.Parent.Parent.Controls.IndexOf($this.Parent)+1
                            $tmpheader = [System.Windows.Forms.Label]$this.Parent.Parent.Controls[$idx]
                            $idx += 1
                            $tmp = [System.Windows.Forms.ComboBox]$this.Parent.Parent.Controls[$idx]

                            if($this.tag -eq "-")
                            {
                                $tmpheader.Visible = $false
                                $tmp.Visible = $false
                            }
                            else
                            {
                                $tmpheader.Visible = $true
                                $tmp.Visible = $true

                                $tmp.Items.Clear();
                                $this.tag.Split("|") | ForEach-Object {
                                    $tmp.Items.Add($_) | Out-Null
                                }
                                $tmp.SelectedIndex = 0
                            }

                            if($this.checked)
                            {
                                $this.parent.tag = $this.Text
                            }
                        })

                        if($OtherAttributes["Name"] -ne $null)
                        {
                            $sctrl.Name = $OtherAttributes["Name"]
                        }

                        $sctrl.Controls.Add($sctrl_chd)
                        $hpos += $sctrl_chd.PreferredSize.Width
                    }
                }
                else
                {
                    #combobox
                    $sctrl = New-Object System.Windows.Forms.ComboBox
                    $sctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
                    $sctrl.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                    if($Size -ne 0 -and $Size[0] -gt 0)
                    {
                        $sctrl.Size = New-Object System.Drawing.Size($size[0], 30)
                    }
                    $sctrl.add_SelectedIndexChanged({
                        if($this.Parent -ne $null)
                        {
                            $idx = $this.Parent.Controls.IndexOf($this)+1
                            $tmpheader = [System.Windows.Forms.Label]$this.Parent.Controls[$idx]
                            $idx = $this.Parent.Controls.IndexOf($this)+2
                            $tmp = [System.Windows.Forms.ComboBox]$this.Parent.Controls[$idx]

                            if($this.SelectedItem.Value -eq "-")
                            {
                                $tmpheader.Visible = $false
                                $tmp.Visible = $false
                            }
                            else
                            {
                                $tmpheader.Visible = $true
                                $tmp.Visible = $true

                                $tmp.Items.Clear();
                                $this.SelectedItem.Value.Split("|") | ForEach-Object {
                                    $tmp.Items.Add($_) | Out-Null
                                }
                                $tmp.SelectedIndex = 0
                            }
                        }
                    })

                    $sctrl.DisplayMember = "text"
                    $sctrl.ValueMember = "value"
                    $OtherAttributes["Elements"] | ForEach-Object {
                        $tmp = New-Object ListItem($_.parent, $_.child)
                        $sctrl.Items.Add($tmp) | Out-Null
                    }

                    if($OtherAttributes -ne $null)
                    {
                        foreach($key in $OtherAttributes.Keys)
                        {
                            switch($key)
                            {
                                "DefaultIndex" {
                                    $sctrl.SelectedIndex = $OtherAttributes["DefaultIndex"]
                                    $blnHide = ($sctrl.SelectedItem.Value -eq '-')
                                }

                                "NoNewLine" {
                                    $NoNewLine = $OtherAttributes["NoNewLine"]
                                }

                                default {
                                    try {
                                        $ctrl.$($key) = $OtherAttributes[$key]
                                    }
                                    catch {

                                    }
                                }
                            }
                        }
                    }
                }
                $col+= $sctrl
                if(!$NoNewLine)
                {
                    $global:vpos += 35
                }

                if($OtherAttributes["Style"] -ne "Treeview")
                {
                    # Child caption
                    $sctrl = New-Object System.Windows.Forms.Label
                    $sctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
                    $sctrl.Font = New-Object System.Drawing.Font("arial",8,[System.Drawing.FontStyle]::Bold);
                    $sctrl.AutoSize = $true
                    $sctrl.Text = $OtherAttributes["ChildCaption"]
                    $sctrl.TabStop = $false
                    if($blnHide)
                    {
                        $sctrl.Visible = $false
                    }
                    $col+= $sctrl
                    $global:vpos += 20

                    # Child Dropdown
                    $sctrl = New-Object System.Windows.Forms.ComboBox
                    $sctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
                    $sctrl.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                    if(-not [string]::IsNullOrEmpty($iniChild))
                    {
                        $iniChild.Split("|") | ForEach-Object {
                            $sctrl.Items.Add($_) | Out-Null
                        }
                        $iniChild = ""
                        $sctrl.SelectedIndex = 0
                    }

                    #TODO: Set value using value[1]
                    if($value.Count -gt 1)
                    {
                        ## search combobox
                        $tmp = $sctrl.FindStringExact($value[1])
                        if($tmp -ne -1) {$sctrl.SelectedIndex = $tmp}
                    }

                    if($Size.Count -gt 0 -and $Size[0] -gt 0)
                    {
                        $sctrl.Size = New-Object System.Drawing.Size($size[0], 30)
                    }
                    if($blnHide)
                    {
                        $sctrl.Visible = $false
                    }
                    $col+= $sctrl
                    if($OtherAttributes -ne $null)
                    {
                        if($OtherAttributes["Name"] -ne $null)
                        {
                            $sctrl.Name = $OtherAttributes["Name"] + "_Child"
                        }
                        if($OtherAttributes["NoNewLine"] -ne $null)
                        {
                            $NoNewLine = $OtherAttributes["NoNewLine"]
                        }
                    }
                    if($NoNewLine)
                    {
                        $global:vpos += 35
                    }
                }
                $ctrl = $col
            }
        }

        "checkbox" {
            $ctrl = New-Object System.Windows.Forms.CheckBox
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            $ctrl.AutoSize = $true #New-Object System.Drawing.Size($size[0], 30)
            $tmp = $false
            if($value -ne $null)
            {
                [Boolean]::TryParse($value[0], [ref]$tmp) | Out-Null
            }
            $ctrl.Checked = $tmp
            if($mode -ne "edit")
            {
                $ctrl.Enabled = $false
            }
            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "Bold" {
                            $oldFont = $ctrl.Font
                            $Font = New-Object System.Drawing.Font($oldFont.FontFamily,$oldFont.Size,[System.Drawing.FontStyle]::Bold)
                            $ctrl.Font = $Font
                        }

                        "Help" {
                            $col = @()
                            $col += $ctrl
                            if($ctrl.AutoSize)
                            {
                                $global:hpos += $ctrl.PreferredSize.Width
                            }
                            else
                            {
                                $global:hpos += $ctrl.Width + 5
                            }
                            $ctrl = Get-UIControl "help" $OtherAttributes["Help"] 0 "" @{NoNewLine=1}
                            $col += $ctrl
                            $ctrl = $col
                        }

                        "NoNewLine" {
                            $global:hpos += $ctrl.PreferredSize.Width + 5
                            $NoNewLine = $OtherAttributes["NoNewLine"]
                        }

                        "Opposite" {
                            $ctrl.Checked = !$ctrl.Checked
                        }

                        "Required" {
                            $ctrl.Add_Validating({
                                if(!$this.Checked)
                                {
                                    $this.FindForm().Tag.SetError($this, "You must check this box in order to continue");
                                    $_.Cancel = $true
                                }
                                else
                                {
                                    $this.FindForm().Tag.SetError($this, "");
                                }
                            })
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }
            }

            if(!$NoNewLine)
            {
                 $global:vpos += 35
            }

            If($OtherAttributes -ne $null -and $OtherAttributes["ToggleChildDisplay"] -ne $null)
            {
                if($OtherAttributes["ToggleChildDisplay"].Count -gt 1)
                {
                    $arrTmp = $OtherAttributes["ToggleChildDisplay"]
                }
                else
                {
                    $tmp = $OtherAttributes["ToggleChildDisplay"].ToString()
                    if($tmp.indexOf(",") -eq -1)
                    {
                        $tmp = "800,$tmp"
                    }
                    $arrTmp = $tmp -split ","
                }
                [array]$arrSize = foreach($tmp in $arrTmp) {([int]::parse($tmp))}

                $col = @()
                $col += $ctrl
                $tmp = $ctrl | Select-Object -first 1
                $tmp.Add_CheckedChanged({
                    $idx = $this.Parent.Controls.IndexOf($this)

                    # if it has help control
                    if($this.Parent.Controls[$($idx+1)] -is [System.Windows.Forms.Label])
                    {
                        $idx += 1
                    }

                    $tmp = $this.Checked
                    if($this.tag -eq "OppositeToggleChildDisplay")
                    {
                        $tmp = !$tmp
                    }
                    $this.Parent.Controls[$($idx+1)].Visible = !$tmp
                    $this.Parent.Controls[$($idx+2)].Visible = $tmp
                })


                $blnChildToggle = $false
                if($OtherAttributes["OppositeToggleChildDisplay"] -ne $null)
                {
                    $ctrl.tag = "OppositeToggleChildDisplay"
                    $blnChildToggle = !$blnChildToggle
                }
                $global:hpos = 0
                $tmp = Get-UIControl panel "ChildPanelUnChecked" $arrSize "" @{Visible=!$blnChildToggle}
                $col += $tmp

                $global:hpos = 0
                $tmp = Get-UIControl panel "ChildPanelChecked" $arrSize "" @{Visible=$blnChildToggle}
                $col += $tmp

                $ctrl = $col

                $global:vpos += [int]$arrSize[1]
            }
        }

        "datagrid" {
            $ctrl = New-Object System.Windows.Forms.DataGridView
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            #$ctrl.Size = New-Object System.Drawing.Size(790, 420);
            $ctrl.ColumnHeadersHeightSizeMode = "EnableResizing"
            #$ctrl.EditMode = [System.Windows.Forms.DataGridViewEditMode]::EditOnEnter  #EditOnEnter, EditOnF2, EditOnKeystroke, *EditOnKeystrokeOrF2, EditProgrammatically
            $ctrl.SelectionMode = "FullRowSelect"   # CellSelect, ColumnHeaderSelect, FullColumnSelect, FullRowSelect, *RowHeaderSelect
            $ctrl.MultiSelect =$false
            $ctrl.AllowUserToResizeColumns = $true
            $ctrl.AllowUserToResizeRows = $false

            if($OtherAttributes -ne $null)
            {
                if($OtherAttributes["AllowUserToAddRows"] -ne $null)
                {
                    # default is true
                    $ctrl.AllowUserToAddRows = $OtherAttributes["AllowUserToAddRows"]
                }

                if($OtherAttributes["AllowUserToDeleteRows"] -ne $null)
                {
                    # default is true
                    $ctrl.AllowUserToDeleteRows = $OtherAttributes["AllowUserToDeleteRows"]
                }
            }

            if($Size.Count -eq 2)
            {
                $ctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
                $ctrl.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::None
            }
            else
            {
                $ctrl.Autosize = $true
                $ctrl.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::AllCells #AllCells, AllCellsExceptHeader, ColumnHeader, DisplayedCells, DisplayedCellsExceptHeader, Fill, *None
            }

            if($mode -ne "edit")
            {
                $ctrl.ReadOnly = $true
            }

            # Columns
            if($OtherAttributes -ne $null)
            {
                if($OtherAttributes["Elements"] -ne $null)
                {
                    # Elements format: Field,HeaderText,ColumnControlType,Width,DisplayFormat
                    $i = 0
                    $OtherAttributes["Elements"] -split "," | ForEach-Object {
                        $arr = $_.split("|")

                        $field = $arr[0] -replace "\W",""
                        $tmp = ""
                        if($arr.Length -gt 2) {$tmp = $arr[2]}
                        switch($tmp)
                        {
                            "button" {
                                $idColumn = New-Object System.Windows.Forms.DataGridViewButtonColumn
                            }

                            "checkbox" {
                                $idColumn = New-Object System.Windows.Forms.DataGridViewCheckBoxColumn
                            }

                            "dropdown" {
                                $idColumn = New-Object System.Windows.Forms.DataGridViewComboBoxColumn
                                $idColumn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                                $idColumn.DataPropertyName = "Value"

                                if($OtherAttributes["{0}_DataSource" -f $field] -ne $null)
                                {
                                    $objDS = $OtherAttributes["{0}_DataSource" -f $field]
                                    if($objDS -is [System.String])
                                    {
                                        $objDS -split "," | ForEach-Object {
                                            $idColumn.Items.Add($_) | Out-Null
                                        }
                                    }
                                    else
                                    {
                                        $OtherAttributes["DisplayMember"] = "Text"
                                        $OtherAttributes["ValueMember"] = "Value"
                                        $col = @()
                                        $OtherAttributes["{0}_DataSource" -f $field] | ForEach-Object {
                                            if($_ -is [ListItem])
                                            {
                                                $tmp = $_
                                            }
                                            else
                                            {
                                                $tmp = New-Object ListItem($_.$($OtherAttributes["DisplayMember"]), $_.$($OtherAttributes["ValueMember"]))
                                            }
                                            $col += $tmp
                                        }
                                        $idColumn.DataSource = $col
                                        $idColumn.DisplayMember = $OtherAttributes["DisplayMember"]
                                        $idColumn.ValueMember = $OtherAttributes["ValueMember"]
                                    }
                                }
                            }

                            "link" {
                                $idColumn = New-Object System.Windows.Forms.DataGridViewLinkColumn
                            }

                            "image" {
                                $idColumn = New-Object System.Windows.Forms.DataGridViewImageColumn
                            }

                            default {
                                $idColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
                            }
                        }

                        # Field
                        $idColumn.Name = $field
                        $idColumn.ReadOnly = $arr[0].ToString().Contains("#")
                        $idColumn.Visible = !$arr[0].ToString().Contains("*")
                        if($arr[0].ToString().Contains("~"))
                        {
                            $idColumn.SortMode = [System.Windows.Forms.DataGridViewColumnSortMode]::NotSortable
                        }

                        # Header
                        $tmp = ""
                        if($arr.Length -gt 1)  {$tmp = $arr[1]}
                        if($tmp -eq "")
                        {
                            $idColumn.HeaderText = $field
                        }
                        else
                        {
                            $idColumn.HeaderText = $tmp
                        }

                        # Width
                        if($arr.Length -gt 3 -and $(IsNumeric($arr[3])))
                        {
                            $idColumn.Width = [Decimal]$arr[3]
                            $idColumn.AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::None
                        }

                        # 4-Format
                        if($arr.Length -gt 4)
                        {
                            $idColumn.Format = $arr[4]
                        }

                        $ctrl.Columns.Add($idColumn) | Out-Null
                    }
                }

                if($OtherAttributes["InMemory"] -eq $null -and ($ctrl.AllowUserToAddRows -or $ctrl.AllowUserToDeleteRows -or $CanUpdate))
                {
                    $cmdColumn = New-Object System.Windows.Forms.DataGridViewLinkColumn
                    $cmdColumn.Name = "_cmd"
                    $cmdColumn.HeaderText = ""
                    $cmdColumn.Width = 50
                    $ctrl.Columns.Add($cmdColumn) | Out-Null
                }
            }
            elseif($value -ne $null)
            {
                # Manual composing columns and data
                $value[0] | ForEach-Object {$_.PSObject.Properties} | ForEach-Object {
                    $ctrl.Columns.Add($_.Name, $_.Name) | Out-Null
                    $ctrl.Columns[$ctrl.Columns.Count-1].AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::AllCells
                }
            }

            # Add command cell
            if($this.tag -ne $null)
            {
                $tmp = Get-Instr $this.Tag.ToString()  "Update=" ";"
                $CanUpdate = ![string]::IsNullOrEmpty($tmp)
            }


            # Data
            if($value -ne $null)
            {
                Switch($value[0].GetType().Name)
                {
                    {($_ -eq "HashTable") -or ($_ -eq "SPPropertyBag") -or ($_ -eq 'Dictionary`2')} {
                        $value[0].Keys | ForEach-Object {
                            $idx = $ctrl.Rows.Add()

                            $ctrl.Rows[$idx].Cells[0].Value = $_

                            if($value[0][$_] -eq $null)
                            {
                                $ctrl.Rows[$idx].Cells[1].Value = ""
                            }
                            else
                            {
                                $ctrl.Rows[$idx].Cells[1].Value = $value[0][$_]
                            }

                            if($ctrl.Columns.Count -gt 2 -and $ctrl.AllowUserToDeleteRows)
                            {
                                $ctrl.Rows[$idx].Cells[2].Value = "Delete"
                            }
                        }
                    }
                    "String" { # just string array
                        $value | ForEach-Object {
                            $ctrl.Rows.Add($_) | Out-Null
                        }
                    }
                    default {
                        $value | ForEach-Object {
                            $dataRow = $_
                            $idx = $ctrl.Rows.Add()
                            $ctrl.Columns | ForEach-Object {
                                if($ctrl.Columns.Contains("_cmd") -and $_.Index -eq $($ctrl.Columns.Count-1))
                                {
                                    if($ctrl.AllowUserToDeleteRows)
                                    {
                                        $ctrl.Rows[$idx].Cells[$_.Index].Value = "Delete"
                                    }
                                }
                                else
                                {
                                    $ctrl.Rows[$idx].Cells[$_.Index].Value = $dataRow.($_.Name)
                                }
                            }
                        }
                    }
                }
            }

            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "NoNewLine" {
                            $NoNewLine = $OtherAttributes[$key]
                        }

                        "AllowUserToUpdateRows" {
                            if($OtherAttributes[$key])
                            {
                                $ctrl.tag = "Update=1"
                            }
                        }

                        "AlternatingColor" {
                            $ctrl.AlternatingRowsDefaultCellStyle.BackColor = $OtherAttributes[$key]
                        }

                        "ColumnHeaderBackColor" {
                            $ctrl.ColumnHeadersDefaultCellStyle.BackColor = $OtherAttributes[$key]
                        }

                        "ColumnHeaderForeColor" {
                            $ctrl.ColumnHeadersDefaultCellStyle.ForeColor = $OtherAttributes[$key]
                        }

                        "SelectionBackColor" {
                            $ctrl.DefaultCellStyle.SelectionBackColor = $OtherAttributes[$key]
                        }

                        "SelectionForeColor" {
                            $ctrl.DefaultCellStyle.SelectionForeColor = $OtherAttributes[$key]
                        }

                        "RowHeaderBackColor" {
                            $ctrl.RowHeadersDefaultCellStyle.BackColor = $OtherAttributes[$key]
                        }

                        "Required" {
                            $ctrl.Add_Validating({
                                if($this.Rows.Count -eq 1 -and $this.Rows[0].IsNewRow)
                                {
                                    $this.FindForm().Tag.SetError($this, "Required field");
                                    $_.Cancel = $true
                                }
                                else
                                {
                                    $this.FindForm().Tag.SetError($this, "")
                                }
                            })
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }
            }

            # Add CellContentClick event for DataGridViewLinkCell
            if($($ctrl.Columns | Where-Object {$_.CellType.Name -eq "DataGridViewLinkCell"}) -ne $null)
            {
                $ctrl.add_CellContentClick({
                    if($this.Columns[$_.ColumnIndex].CellType.Name -eq "DataGridViewLinkCell")
                    {
                        $tmp = $this[$_.ColumnIndex,$_.RowIndex].Value
                        if($tmp -like "http*")
                        {
                            Open-IETabs $tmp
                        }
                    }
                })
            }

            if($OtherAttributes["InMemory"] -eq $null)
            {
                $ctrl.add_UserAddedRow({
                    $this[$($this.Columns.Count-1), $($this.Rows.Count - 2)].Value  = "Insert"
                })

                $ctrl.add_CellValueChanged({
                    $cmdCell = $this[$($this.Columns.Count-1), $($this.CurrentRow.Index)]
                    if($_.ColumnIndex -eq $($this.Columns.Count-1))  # Cmd column
                    {
                        if($cmdCell.Value -eq "CancelEdit")
                        {
                            for($i=0;$i -lt $this.columns.Count;$i++)
                            {
                                if($this[$i, $this.CurrentRow.Index].tag -ne $null)
                                {
                                    $this[$i, $this.CurrentRow.Index].Value = $this[$i, $this.CurrentRow.Index].tag
                                    $this[$i, $this.CurrentRow.Index].tag = $null
                                }
                            }
                            $cmdCell.Value = "Reset"
                        }

                        if($cmdCell.Value -eq "Reset")
                        {
                            if($this.AllowUserToDeleteRows)
                            {
                                $cmdCell.Value = "Delete"
                            }
                            else
                            {
                                $cmdCell.Value = ""
                            }
                        }
                    }
                    elseif(!$this.ReadOnly -and $cmdCell.Value -ne "Insert")   # not new row
                    {
                        $cmdCell.Value = "Update"
                    }
                })

                $ctrl.add_CellBeginEdit({
                    $tmp = $null
                    if($this.tag -ne $null)
                    {
                        $tmp = Get-Instr $this.Tag.ToString()  "Update=" ";"
                    }

                    # no update flag
                    if([string]::IsNullOrEmpty($tmp))
                    {
                        # not the new row
                        if($_.RowIndex -ne $($this.Rows.Count-1) -and $this[$($this.columns.Count-1),$_.RowIndex].Value -ne "Insert")
                        {
                            $_.Cancel = $true
                        }
                    }
                })
            }

            $ctrl.add_CellValidating({
                $cmdCell = $this[$_.ColumnIndex, $_.RowIndex]
                if($_.ColumnIndex -ne $($this.Columns.Count-1))  # Cmd column
                {
                    $cmdCell.Tag = $this[$_.ColumnIndex, $_.RowIndex].Value
                }
            })

            $ctrl.Add_AutoSizeChanged({
                Get-UIMessageBox "SizeChanged"
                if($this.AutoSizeColumnsMode -ne [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::None)
                {
                    $tmp = $this.RowHeadersWidth
                    if(($this.ScrollBars -and [System.Windows.Forms.ScrollBars]::Vertical) -ne [System.Windows.Forms.ScrollBars]::None)
                    {
                        $tmp += [System.Windows.Forms.SystemInformation]::VerticalScrollBarWidth
                    }

                    $this.Columns | ForEach-Object {
                        $tmp += $_.Width + 2
                    }
                    $this.Width = $tmp
                }
            })

            if(!$NoNewLine)
            {
                 $global:vpos += $ctrl.Height + 15
            }
        }

        {($_ -eq "dropdown") -or ($_ -eq "listbox") -or ($_ -eq "checklistbox")} {
            switch($_)
            {
                "listbox" {
                    $ctrl = New-Object System.Windows.Forms.ListBox
                    if($Size.Count -gt 0 -and $Size[0] -gt 0)
                    {
                        if($Size.Count -eq 1)
                        {
                            $ctrl.Width = $size[0]
                        }
                        else
                        {
                            $ctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
                        }
                    }
                    else
                    {
                        $ctrl.AutoSize = $true
                    }
                }
                "dropdown" {
                    #https://msdn.microsoft.com/en-us/library/system.windows.forms.combobox_properties(v=vs.110).aspx
                    $ctrl = New-Object System.Windows.Forms.ComboBox
                    $ctrl.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
                    if($Size.Count -gt 0 -and $Size[0] -gt 0)
                    {
                        $ctrl.Size = New-Object System.Drawing.Size($size[0], 30)
                    }
                }
                "checklistbox" {
                    $ctrl = New-Object System.Windows.Forms.CheckedListBox
                    if($Size.Count -gt 0 -and $Size[0] -gt 0)
                    {
                        if($Size.Count -eq 1)
                        {
                            $ctrl.Width = $size[0]
                            $ctrl.Height = 75
                        }
                        else
                        {
                            $ctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
                        }
                    }
                    else
                    {
                        $ctrl.AutoSize = $true
                    }
                    $ctrl.CheckOnClick = $true
                }
            }
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            $ctrl.DisplayMember = "text"
            $ctrl.ValueMember = "value"

            if($mode -ne "edit")
            {
                $ctrl.Enabled = $false
            }
            $blnFirstItemSelectable = $true

            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "AcceptNewValue" {
                            if($_ -eq "dropdown")
                            {
                                $ctrl.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDown
                            }
                        }

                        "DefaultIndex" {
                            if($mode -eq "edit" -and $OtherAttributes["DefaultIndex"] -lt $ctrl.Items.count)
                            {
                                $ctrl.SelectedIndex = $OtherAttributes["DefaultIndex"]
                            }
                        }

                        "DefaultText" {
                            if($mode -eq "edit")
                            {
                                if($OtherAttributes["DefaultText"].StartsWith("*"))
                                {
                                    $tmp = $OtherAttributes["DefaultText"].ToString().Substring(1)
                                    $blnFirstItemSelectable = $false
                                }
                                else
                                {
                                    $tmp = $OtherAttributes["DefaultText"]
                                }

                                if($ctrl.DataSource -ne $null)
                                {
                                    $dt = $ctrl.DataSource
                                    $dr = $dt.NewRow()
                                    $dr[$ctrl.DisplayMember] = $tmp
                                    $dt.Rows.InsertAt($dr, 0)
                                    $ctrl.DataSource = $dt
                                }
                                else
                                {
                                    $ctrl.Items.Insert(0,$tmp)
                                    if($ctrl.SelectedIndex -eq -1)
                                    {
                                        $ctrl.SelectedIndex = 0
                                    }
                                }
                            }
                        }

                        "Elements" {
                            if($OtherAttributes["Elements"] -is [array])
                            {
                                if($OtherAttributes["Elements"][0].GetType().Name -eq "String" -or $OtherAttributes["Elements"][0].GetType().Name -Like "Int*")
                                {
                                    $ctrl.Items.AddRange($OtherAttributes["Elements"])	| Out-Null

                                    $value | ForEach-Object {
                                        $tmp = $ctrl.FindStringExact($_)
                                        if($tmp -ne -1) {
                                            if($ControlType -eq "checklistbox")
                                            {
                                                $ctrl.SetItemChecked($tmp, $true)
                                            }
                                            elseif($ControlType -eq "dropdown")
                                            {
                                                $ctrl.SelectedIndex = $tmp
                                            }
                                            else
                                            {
                                                $ctrl.SetSelected($tmp, $true)
                                            }
                                        }
                                    }
                                }
                                elseif($OtherAttributes["Elements"][0].GetType().Name -ne "DataTable")
                                {
                                    if($OtherAttributes["ValueMember"] -eq $null) {$OtherAttributes["ValueMember"]="value"}
                                    if($OtherAttributes["DisplayMember"] -eq $null) {$OtherAttributes["DisplayMember"]="text"}

                                    $OtherAttributes["Elements"] | ForEach-Object {
                                        if($_ -is [ListItem])
                                        {
                                            $tmp = $_
                                        }
                                        else
                                        {
                                            $tmp = New-Object ListItem($_.$($OtherAttributes["DisplayMember"]), $_.$($OtherAttributes["ValueMember"]))
                                        }
                                        $ctrl.Items.Add($tmp) | Out-Null

                                        if($tmp.Value -eq $value)
                                        {
                                            if($ControlType -eq "checklistbox")
                                            {
                                                $ctrl.SetItemChecked($ctrl.Items.Count-1, $true)
                                            }
                                            elseif($ControlType -eq "dropdown")
                                            {
                                                $ctrl.SelectedIndex = $ctrl.Items.Count-1
                                            }
                                            else
                                            {
                                                $ctrl.SelectedItem = $tmp
                                            }
                                        }
                                    }

                                    $ctrl.DisplayMember = "text"
                                    $ctrl.ValueMember = "value"
                                }
                                else
                                {
                                    $ctrl.DataSource = $OtherAttributes["Elements"]
                                }


                                #Adjust height to trim extra space (if there are only a few items - each item occupies 18 pixel, autosize height=96 pixel)
                                if($ctrl.AutoSize -and $ctrl.Items.count -gt 0 -and $ctrl.Items.count -lt 6)
                                {
                                    $ctrl.Height = $ctrl.Items.Count * 18
                                }
                            }
                            else
                            {
                                if($OtherAttributes["Elements"] -is [System.String])
                                {
                                    switch($OtherAttributes["Elements"])
                                    {
                                        "Month" {
                                            $a = New-Object System.GlobalTimeZones.DateTimeFormatInfo
                                            $b = $a.MonthNames
                                            $ctrl.Items.AddRange($b)

                                            if($value -ne $null)
                                            {
                                                SetDropdownSelectedItem $ctrl $value
                                            }
                                        }
                                        "States" {

                                        }
                                        {$_ -like "*h:??"} {
                                            $arr = $_ -split ":"
                                            if($arr[0][$arr[0].Length-1] -ceq "H")
                                            {
                                                $hour = 23
                                            }
                                            else
                                            {
                                                $hour = 11
                                            }
                                            for($i=1;$i -le $hour;$i++)
                                            {
                                                $tmp = New-Object DateTime(1,1,1,$i,0,0)
                                                $ctrl.Items.Add($tmp.ToString("$($arr[0]):00")) | Out-Null

                                                $tmp = $tmp.AddMinutes([int]$arr[1])
                                                While($tmp.minute -ne 0)
                                                {
                                                    $ctrl.Items.Add($tmp.ToString($("{0}:{1}" -f $arr[0], $tmp.Minute.ToString("00")))) | Out-Null
                                                    $tmp = $tmp.AddMinutes([int]$arr[1])
                                                }
                                            }

                                            if($value -ne $null)
                                            {
                                                SetDropdownSelectedItem $ctrl $value
                                            }
                                        }
                                        "TimeZone" {
                                            $ctrl.DisplayMember = "text"
                                            $ctrl.ValueMember = "value"
                                            [Microsoft.SharePoint.SPRegionalSettings]::GlobalTimeZones | ForEach-Object {
                                                $tmp = New-Object ListItem($_.Description, $_.ID)
                                                $ctrl.Items.Add($tmp) | Out-Null
                                            }
                                        }
                                        default {
                                            $blnPlainText = ($OtherAttributes["Elements"].ToString().IndexOf("|") -eq -1)
                                            $OtherAttributes["Elements"] -split "," | ForEach-Object {
                                                if(!$blnPlainText -or $_.indexOf("|") -ne -1)
                                                {
                                                    if($_.IndexOf("|") -eq -1) {$_ += "|$($_)"}
                                                    $ctrl.DisplayMember = "text"
                                                    $ctrl.ValueMember = "value"
                                                    $arr = $_.Split("|")
                                                    if($arr[1].EndsWith("+"))
                                                    {
                                                        $tmp = New-Object ListItem($arr[0], $arr[0])
                                                        $tmp.Tag = $arr[1].Replace("+",",").Substring(0, $arr[1].Length-1)
                                                        $ctrl.add_SelectedIndexChanged({
                                                            if($this.selectedindex -gt 0 -and $this.selectedindex -lt $($this.Items.Count-1))
                                                            {
                                                                Set-UITooltip $this $("VMs in this set: " + $this.SelectedItem.Tag) -Show:$true
                                                            }
                                                        })
                                                        $ctrl.Items.Add($tmp) | Out-Null
                                                    }
                                                    else	# value and text are both provided
                                                    {
                                                        $tmp = New-Object ListItem($arr[1], $arr[0])
                                                        $ctrl.Items.Add($tmp) | Out-Null
                                                    }
                                                    if($value -ne $null)
                                                    {
                                                        if(($value -is [array] -and $value -Contains $_) -or ($value -eq $arr[0]))
                                                        {
                                                            if($ControlType -eq "checklistbox")
                                                            {
                                                                $ctrl.SetItemChecked($ctrl.Items.Count-1, $true)
                                                            }
                                                            elseif($ControlType -eq "dropdown")
                                                            {
                                                                $ctrl.SelectedIndex = $ctrl.Items.Count-1
                                                            }
                                                            else
                                                            {
                                                                $ctrl.SetSelected($ctrl.Items.Count-1, $true)
                                                            }
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    $ctrl.Items.Add($_)	| Out-Null
                                                    if($value -ne $null)
                                                    {
                                                        if(($value -is [array] -and $value -Contains $_) -or ($value -eq $_))
                                                        {
                                                            if($ControlType -eq "checklistbox")
                                                            {
                                                                $ctrl.SetItemChecked($ctrl.Items.Count-1, $true)
                                                            }
                                                            elseif($ControlType -eq "dropdown")
                                                            {
                                                                $ctrl.SelectedIndex = $ctrl.Items.Count-1
                                                            }
                                                            else
                                                            {
                                                                $ctrl.SetSelected($ctrl.Items.Count-1, $true)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                elseif($OtherAttributes["Elements"] -is [System.Data.DataTable])
                                {
                                    $ctrl.DisplayMember = $OtherAttributes["Elements"].Columns[0].ColumnName
                                    $ctrl.ValueMember = $OtherAttributes["Elements"].Columns[0].ColumnName
                                    $ctrl.DataSource = $OtherAttributes["Elements"]
                                }
                                else
                                {
                                    # You can pass a collection containing 2 properties - Text and Value
                                    $OtherAttributes["Elements"] | ForEach-Object {
                                        if($_ -is [System.String])
                                        {
                                            $tmp = New-Object ListItem($_, $_)
                                            $val = $_
                                        }
                                        else
                                        {
                                            $tmp = New-Object ListItem($_.$($ctrl.DisplayMember), $_.$($ctrl.ValueMember))
                                            $val = $_.$($ctrl.ValueMember)
                                        }
                                        $ctrl.Items.Add($tmp) | Out-Null

                                        if($value -ne $null)
                                        {
                                            if(($value -is [array] -and $value -Contains $val) -or ($value -eq $val))
                                            {
                                                if($ControlType -eq "checklistbox")
                                                {
                                                    $ctrl.SetItemChecked($ctrl.Items.Count-1, $true)
                                                }
                                                elseif($ControlType -eq "dropdown")
                                                {
                                                    $ctrl.SelectedIndex = $ctrl.Items.Count-1
                                                }
                                                else
                                                {
                                                    $ctrl.SetSelected($ctrl.Items.Count-1, $true)
                                                }
                                            }
                                        }
                                    }
                                    $ctrl.DisplayMember = "text"
                                    $ctrl.ValueMember = "value"
                                }
                            }

                            if($selectedValue -ne $null)
                            {
                                $tmp = $ctrl.FindStringExact($selectedValue)
                                $ctrl.SelectedIndex = $tmp
                            }
                        }

                        "TriggerOKButton" {
                            if($ControlType -eq "ListBox")
                            {
                                $ctrl.Add_DoubleClick({
                                    $btnOK = $this.FindForm().Controls.Find("btnOK", $true)[0]
                                    if($btnOK -ne $null)
                                    {
                                        $btnOK.PerformClick()
                                    }
                                })
                            }
                        }

                        "Help" {
                            if($ctrl.Visible)
                            {
                                $lastCtrl = $col | Select-Object -Last 1
                                $global:hpos = $lastCtrl.Left + $lastctrl.PreferredSize.Width + 5
                                $sctrl = Get-UIControl "help" $OtherAttributes["Help"] 0 "" @{NoNewLine=1}
                                $col += $sctrl
                                $global:hpos = 22
                            }
                        }

                        "NoNewLine" {
                            $global:hpos += $ctrl.Width + 5
                            $NoNewLine = $true
                        }

                        "ElementsDataSource"
                        {
                            $ctrl.Tag = $OtherAttributes["ElementsDataSource"]
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }


                if($OtherAttributes["Required"] -ne $null)
                {
                    if($blnFirstItemSelectable)
                    {
                        $ctrl.Add_Validating({
                            # Check if it is for people picker
                            $idx = $this.Parent.Controls.IndexOf($this)+1
                            $tmp = $this.Parent.Controls[$idx]

                            If($tmp -ne $null -and $tmp.Name -like "*Picker")
                            {
                                if($this.Items.count -eq 0)
                                {
                                    $this.FindForm().Tag.SetError($this, "Please select a person")
                                    $_.Cancel = $true
                                }
                                else
                                {
                                    $this.FindForm().Tag.SetError($this, "")
                                }
                            }
                            else
                            {
                                if($this -is [System.Windows.Forms.CheckedListBox])
                                {
                                    if($this.CheckedItems.Count -eq 0)
                                    {
                                        $this.FindForm().Tag.SetError($this, "Please select an item")
                                        $_.Cancel = $true
                                    }
                                    else
                                    {
                                        $this.FindForm().Tag.SetError($this, "")
                                    }
                                }
                                else
                                {
                                    if($this.SelectedIndex -eq -1)
                                    {
                                        $bad = $true
                                        if($this -is [System.Windows.Forms.Combobox] -and $this.DropDownStyle -eq [System.Windows.Forms.ComboBoxStyle]::DropDown)
                                        {
                                            $bad = ($this.Text.Trim() -eq "")
                                        }
                                        if($bad)
                                        {
                                            $this.FindForm().Tag.SetError($this, "Please select an item")
                                            $_.Cancel = $true
                                        }
                                        else
                                        {
                                            $this.FindForm().Tag.SetError($this, "")
                                        }
                                    }
                                    else
                                    {
                                        $this.FindForm().Tag.SetError($this, "")
                                    }
                                }
                            }
                        })
                    }
                    else
                    {
                        $ctrl.Add_Validating({
                            if($this.SelectedIndex -le 0)
                            {
                                $this.FindForm().Tag.SetError($this, "Please select an item")
                                $_.Cancel = $true
                            }
                            else
                            {
                                $this.FindForm().Tag.SetError($this, "")
                            }
                        })
                    }
                }
                elseif(!$blnFirstItemSelectable)
                {
                    $ctrl.Add_Validating({
                        if($this.SelectedIndex -eq 0)
                        {
                            $this.FindForm().Tag.SetError($this, "Please select an item")
                            $_.Cancel = $true
                        }
                        else
                        {
                            $this.FindForm().Tag.SetError($this, "");
                        }
                    })
                }

                if($OtherAttributes["OpenPicker"] -ne $null -and $ControlType -eq "listbox")
                {
                    $ctrl.Add_KeyDown({
                        if ($_.KeyCode -eq "Delete")
                        {
                        for ($i = $this.selectedItems.Count - 1; $i -ge 0; $i--)
                        {
                            $this.Items.Remove($this.selectedItems[$i])
                        }
                        }
                    })

                    $col = @()
                    $col += $ctrl
                    $ctrl = New-Object System.Windows.Forms.Button
                    $ctrl.Location = New-Object System.Drawing.Point($($global:hpos+$size[0]), $global:vpos)
                    $ctrl.Size = New-Object System.Drawing.Size(22, 20)
                    $ctrl.Tag = $OtherAttributes["OpenPicker"]
                    $ctrl.Text = "..."
                    $ctrl.Add_Click({
                        $arr = $this.tag -split ","
                        $inFile = Get-UIFileOpenDialog $arr[2] $arr[1] $arr[0] -MultiSelect  #InitialDir, $Filter, Title
                        if(-not [System.String]::IsNullOrEmpty($inFile))
                        {
                            $idx = $this.Parent.Controls.IndexOf($this)-1
                            $tmp = [System.Windows.Forms.ListBox]$this.Parent.Controls[$idx]
                            $inFile | ForEach-Object {
                                if($($tmp.FindString($_) -eq -1))
                                {
                                    $tmp.Items.Add($_)
                                }
                            }
                        }
                    })
                    $col += $ctrl
                    $ctrl = $col
                }

                if($OtherAttributes["PeoplePicker"] -ne $null -or $OtherAttributes["PersonPicker"] -ne $null -or $OtherAttributes["GroupPicker"] -ne $null -or $OtherAttributes["GroupsPicker"] -ne $null)
                {
                    $blnGroup = $($OtherAttributes["GroupPicker"] -ne $null -or $OtherAttributes["GroupsPicker"] -ne $null)
                    if($OtherAttributes["PersonPicker"] -ne $null -or $OtherAttributes["GroupPicker"] -ne $null)
                    {
                        $ctrl.Height = 29
                    }
                    else
                    {
                        $ctrl.SelectionMode = [System.Windows.Forms.SelectionMode]::MultiExtended
                    }
                    $ctrl.DisplayMember = "text"
                    $ctrl.ValueMember = "value"
                    $ctrl.Add_KeyDown({if ($_.KeyCode -eq "Delete") {
                        for ($i = $this.selectedItems.Count - 1; $i -ge 0; $i--)
                        {
                            $this.Items.Remove($this.selectedItems[$i])
                        }
                    }})

                    $col = @()
                    $col += $ctrl
                    $global:hpos += $ctrl.Width + 5

                    $col += $(Get-ADPickerButton $($ctrl.SelectionMode -eq [System.Windows.Forms.SelectionMode]::MultiExtended) $OtherAttributes["PickerFields"] $blnGroup)
                    $ctrl = $col
                }
            }

            if(!$NoNewLine)
            {
                $tmp = $ctrl | Select-Object -First 1
                $global:vpos += $tmp.ClientSize.Height + 20
            }

            If($OtherAttributes -ne $null -and $OtherAttributes["ToggleChildDisplay"] -ne $null)
            {
                if($OtherAttributes["ToggleChildDisplay"].Count -gt 1)
                {
                    $arrTmp = $OtherAttributes["ToggleChildDisplay"]
                }
                else
                {
                    $tmp = $OtherAttributes["ToggleChildDisplay"].ToString()
                    if($tmp.indexOf(",") -eq -1)
                    {
                        $tmp = "800,$tmp"
                    }
                    $arrTmp = $tmp -split ","
                }
                [array]$arrSize = foreach($tmp in $arrTmp) {([int]::parse($tmp))}

                $col = @()
                $col += $ctrl
                $tmp = $ctrl | Select-Object -First 1
                $tmp.Add_SelectedIndexChanged({
                    $idx = $this.Parent.Controls.IndexOf($this)

                    # if it has help control
                    if($this.Parent.Controls[$($idx+1)] -is [System.Windows.Forms.Label])
                    {
                        $idx += 1
                    }

                    $i=0
                    do {
                        $this.Parent.Controls[$($idx+$i+1)].Visible = $($i -eq $this.SelectedIndex)
                        $i++
                    } while($i -lt $this.Items.Count)
                })

                $i=0
                $tmp.Items | ForEach-Object {
                    $blnVisible = $($ctrl.SelectedIndex -eq $i)
                    $global:hpos = 0
                    $tmp = Get-UIControl panel "ChildPanel$i" $arrSize "" @{Visible=$blnVisible}
                    $col += $tmp
                    $i++
                }
                $ctrl = $col

                $global:vpos += [int]$arrSize[1]
            }
        }

        "groupbox" {
            $ctrl = New-Object System.Windows.Forms.GroupBox
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            if($size -ne $null -and $size.Count -eq 2)
            {
                 $ctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
            }
            else
            {
                $ctrl.AutoSize = $true
                $ctrl.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
                $ctrl.MinimumSize = New-Object System.Drawing.Size(100,20)
            }
            $ctrl.Text = " {0} " -f $value
            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "NoNewLine" {
                            $global:hpos += $ctrl.Width +5
                            $NoNewLine = $true
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }
            }
        }

        "header" {
            $global:hpos = 22

            $col = @()
            $ctrl = New-Object System.Windows.Forms.Label
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            $ctrl.Font = New-Object System.Drawing.Font("arial",11,[System.Drawing.FontStyle]::Bold)
            $ctrl.Forecolor = "Blue"
            if($value -ne $null)
            {
                $ctrl.Text = $value[0]
            }
            $ctrl.AutoSize = $true
            $col+= $ctrl

            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "Help" {
                            if($ctrl.Visible)
                            {
                                $global:hpos += $col[0].PreferredSize.Width + 5
                                $sctrl = Get-UIControl "help" $OtherAttributes["Help"]
                                $col += $sctrl
                            }
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }
            }
            $global:vpos += 25

            $sctrl = New-Object System.Windows.Forms.Label
            $sctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            $sctrl.AutoSize = $false
            $sctrl.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
            if($size -ne $null)
            {
                 $sctrl.Size = New-Object System.Drawing.Size($size[0], 2)
            }
            else
            {
                 $sctrl.Size = New-Object System.Drawing.Size(600, 2)
            }
            $col+= $sctrl

            $ctrl = $col
            $global:vpos += 10
        }

        "help" {
            $ctrl = New-Object System.Windows.Forms.Label
            $ctrl.AutoSize = $true
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            $ctrl.Font = new-object System.Drawing.font("WebDings", 12, [System.Drawing.FontStyle]::Regular)
            $ctrl.ForeColor = "green"
            $ctrl.Text = "i"

            if($value[0] -like "*.rtf")
            {
                if($value[0] -notlike "?:\*")
                {
                    $tmp = "$env:dp\Help\{0}" -f $value[0]
                }
                else
                {
                    $tmp = $value[0]
                }
                Set-UITooltip $ctrl "Click to see help"
                $ctrl.Add_MouseHover({
                    $this.Cursor = [System.Windows.Forms.Cursors]::Hand
                })
                $ctrl.Add_MouseLeave({
                    try
                    {
                        $this.Cursor = [System.Windows.Forms.Cursors]::Default
                    }
                    catch {}
                })
                $ctrl.tag = $tmp
                if($OtherAttributes -ne $null -and $OtherAttributes["FileNotFound"] -ne $null)
                {
                    $ctrl.Tag += ",{0}" -f $OtherAttributes["FileNotFound"]
                }
                $ctrl.Add_Click({
                    $arr = $this.tag -split ","
                    OpenHelpPopup $arr[0] $arr[1]
                })
            }
            else
            {
                Set-UITooltip $ctrl $value[0].Replace("\n", [System.Environment]::NewLine)
            }
            if($OtherAttributes -ne $null -and $OtherAttributes["NoNewLine"] -ne $null) #used to name NoLineFeed
            {
               $NoNewLine = $true
               $global:hpos += $ctrl.Width + 5
            }
            else
            {
                $global:vpos += 20
            }
        }

        "image" {
            $ctrl = New-Object System.Windows.Forms.PictureBox
            $ctrl.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
            if($Size.Count -gt 0 -and $Size[0] -gt 0)
            {
                 $ctrl.ClientSize = New-Object System.Drawing.Size($size[0], $size[1])
            }
            else
            {
                 $ctrl.ClientSize = New-Object System.Drawing.Size(0,0)
            }
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            $imgNew = ""
            $imgDesc = ""

            if($value -ne $null -and $value[0] -ne "" -and $OtherAttributes["IconElements"] -eq $null)
            {
                $imgNew = $value[0]
            }

            if($OtherAttributes -ne $null)
            {
                if($OtherAttributes["Default"] -ne $null -and $null -eq $value)
                {
                    $value = $OtherAttributes["Default"]
                }

                if($OtherAttributes["Name"] -ne $null)
                {
                    $ctrl.Name = $OtherAttributes["Name"]
                }

                ### don't use "$value -ne $null", change it to "$value.count -gt 0"
                if($OtherAttributes["IconElements"] -ne $null)
                {
                    if($value.count -gt 0)
                    {
                        # A|a.png,B|b.png
                        $col = $OtherAttributes["IconElements"] -split ","
                        ForEach($c in $col)
                        {
                            if($c.Contains("|"))
                            {
                                $blnLocated = $false
                                $arr = $c.split("|")
                                if($value[0] -is [Boolean])
                                {
                                    if(($arr[0] -eq "true" -and $value[0]) -or ($arr[0] -eq "false" -and !$value[0]))
                                    {
                                        $blnLocated = $true
                                    }
                                }
                                elseif($arr[0] -eq $value[0])
                                {
                                    $blnLocated = $true
                                }

                                if($blnLocated)
                                {
                                    if(!$arr[1].Contains("."))
                                    {
                                        $imgNew = $arr[1] + ".png"
                                    }
                                    else
                                    {
                                        $imgNew = $arr[1]
                                    }
                                    if($OtherAttributes["IconDescription"] -ne $null)
                                    {
                                        $imgDesc = $arr[0]
                                    }
                                    break
                                }
                            }
                            else
                            {
                                $imgNew = $c
                                if($OtherAttributes["IconDescription"] -ne $null)
                                {
                                    $imgDesc = $value
                                }
                                break
                            }
                        }
                    }
                    else
                    {
                        $imgNew = $OtherAttributes["IconElements"]
                    }
                }

                if($OtherAttributes["Help"] -ne $null)
                {
                    Set-UITooltip $ctrl $OtherAttributes["Help"]
                }

                if($OtherAttributes["NoNewLine"] -ne $null)
                {
                    $NoNewLine = $OtherAttributes["NoNewLine"]
                }
            }

            if($imgNew -ne "")
            {
                #two types of value - "some.png" or "/a17/pic/svr.png"
                If($imgNew.IndexOf("/") -ne -1)
                {
                    # Uri (ex: http://bing.com/a.png")
                    $webclient = New-Object Net.WebClient
                    $webclient.UseDefaultCredentials = $true
                    $tmp = "$env:dp\Output\{0}" -f [System.IO.Path]::GetRandomFileName()
                    $webclient.DownloadFile($imgNew, $tmp)
                    $img = GetImageFromFile $tmp
                }
                else
                {
                    # local path (ex: c:\img\a.png or a.png in Assets folder)
                    if($imgNew -like "?:\*")
                    {
                        $img = Get-ImagefromFile $imgNew
                    }
                    elseif($imgNew -like "`$env:dp*")
                    {
                        $imgNew = $imgNew.Replace("`$env:dp",$env:dp)
                        #$img = [Drawing.Image]::FromFile($imgNew)
                        $img = Get-ImagefromFile $imgNew
                        #Image img = [Drawing.Image]::FromStream(new MemoryStream(File.ReadAllBytes(path)));
                    }
                    else
                    {
                        $img = Get-ImagefromFile $("$env:dp\Assets\{0}" -f $imgNew)
                    }
                }
                $ctrl.Image = $img
                if($Size.Count -gt 0 -and $Size[0] -gt 0) {}
                else
                {
                    $ctrl.ClientSize = New-Object System.Drawing.Size($img.Width, $img.Height)
                }

                if($imgDesc -ne "")
                {
                    $col = @()
                    $col += $ctrl
                    switch($OtherAttributes["IconDescription"])
                    {
                        # Right side
                        "1" {
                            $global:hpos += $ctrl.ClientSize.Width + 5
                        }
                        # Bottom
                        "2" {
                            $global:hpos = $ctrl.left
                            $global:vpos += $ctrl.Height
                        }
                    }
                    $ctrl = Get-UIControl "label" $imgDesc 0 "" @{NoNewLine=1}

                    # Shift to center
                    if($OtherAttributes["IconDescription"] -eq "2")
                    {
                        $tmp = [int](($ctrl.PreferredSize.Width - $col[0].Width)/2)
                        $ctrl.TextAlign ="TopCenter"
                        $ctrl.Left -= $tmp
                    }

                    $col += $ctrl
                    $ctrl = $col
                }
            }

            if($NoNewLine)
            {
                if($imgDesc -ne "" -and $OtherAttributes["IconDescription"] -eq "2")
                {
                    $global:vpos -= $ctrl[0].ClientSize.Height
                    $global:hpos = $ctrl[0].Left + $ctrl[0].ClientSize.Width + 5
                }
                else
                {
                    $tmp = $ctrl | Select-Object -Last 1
                    $global:hpos += $tmp.ClientSize.Width + 5
                }
            }
            else
            {
                $tmp = $ctrl | Select-Object -First 1
                if($tmp.Visible)
                {
                    $global:vpos += $tmp.ClientSize.Height + 5
                    if($tmp.ClientSize.Height -lt 30)
                    {
                        $global:vpos += $(30 - $tmp.ClientSize.Height)
                    }
                }
            }
        }

        "label" {
            $ctrl = New-Object System.Windows.Forms.Label
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            if($Size.Count -gt 0 -and $Size[0] -gt 0 -and $value -ne $null)
            {
                if($size.Length -gt 1)
                {
                    $ctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
                    #$global:vpos += $size[1]
                }
                else
                {
                    $ctrl.Size = New-Object System.Drawing.Size($size[0], 30)
                }
            }
            else
            {
                $ctrl.AutoSize = $true
            }

            if(![string]::IsNullOrEmpty($value))                                              ###($value -ne $null) -> issue when $value = 0
            {
                $ctrl.Text = $value[0]
            }

            if($OtherAttributes -ne $null)
            {
                if($value -eq $null)
                {
                    if($OtherAttributes["Default"] -ne $null)
                    {
                        $ctrl.Text = $OtherAttributes["Default"]
                    }
                }
                else
                {
                    $ctrl.Tag = $Value -join ","

                    if($OtherAttributes["Format"] -ne $null)
                    {
                        if($OtherAttributes["Format"].EndsWith("[SIZE]") -and $(IsNumeric($value[0])))
                        {
                            $ctrl.Text = Format-SizeWithUnit $value[0] $OtherAttributes["Format"]
                        }
                        elseif($OtherAttributes["Format"].indexOf("[AGE]") -ne -1 -and $($value[0] -is [datetime]))
                        {
                            $ctrl.Text = Format-AgeWithUnit $value[0] $OtherAttributes["Format"]
                        }
                        else
                        {
                            $ctrl.Text = $OtherAttributes["Format"] -f @($value)
                        }
                    }
                    else
                    {
                        $strValue = $value[0].ToString()

                        if($OtherAttributes["Instr"] -ne $null)
                        {
                            $arr = $OtherAttributes["Instr"].split(",")
                            if($arr.Length -eq 0)
                            {
                                $strValue = Get-Instr $strValue $arr[0]
                            }
                            else
                            {
                                $strValue = Get-Instr $strValue $arr[0] $arr[1]
                            }
                        }

                        if($OtherAttributes["Replace"] -ne $null)
                        {
                            $arr = $OtherAttributes["Replace"].split(",")
                            $strValue = $strValue.Replace($arr[0],$arr[1])
                        }

                        $ctrl.Text = $strValue
                    }
                }

                if($OtherAttributes["Name"] -ne $null)
                {
                    $ctrl.Name = $OtherAttributes["Name"]
                }
                if($OtherAttributes["Alignment"] -ne $null)
                {
                    $tmp = [System.Drawing.ContentAlignment]$($OtherAttributes["Alignment"])
                    $ctrl.TextAlign = $tmp
                }

                if($OtherAttributes["FontName"] -ne $null -or $OtherAttributes["Fontsize"] -ne $null)
                {
                    $tmpFont = "Microsoft Sans Serif"
                    if($OtherAttributes["FontName"] -ne $null) { $tmpFont = $OtherAttributes["FontName"] }
                    $tmpSize = 8
                    if($OtherAttributes["FontSize"] -ne $null) { $tmpSize = [int]$OtherAttributes["FontSize"] }
                    $ctrl.Font = New-Object System.Drawing.Font($tmpFont,$tmpSize,[System.Drawing.FontStyle]::Regular);
                }

                if($OtherAttributes["Backcolor"] -ne $null)
                {
                    $ctrl.BackColor = $OtherAttributes["backcolor"]
                }

                if($OtherAttributes["BorderStyle"] -ne $null)
                {
                    $ctrl.BorderStyle = [System.Windows.Forms.BorderStyle]$($OtherAttributes["BorderStyle"])
                }

                if($OtherAttributes["Tooltip"] -ne $null)
                {
                    Set-UITooltip $ctrl $OtherAttributes["Tooltip"]
                }

                if($OtherAttributes["Copy"] -ne $null -and $ctrl.Visible -and $ctrl.Text -ne "")
                {
                    $col = @()
                    $col += $ctrl
                    if($size.Length -gt 1)
                    {
                        $global:hpos += $ctrl.Width + 5
                    }
                    else
                    {
                        $global:hpos += $ctrl.PreferredSize.Width + 5
                    }
                    $global:vpos = $ctrl.top
                    $col += $(Get-CopyButton)
                    $ctrl = $col
                }

                if($OtherAttributes["Help"] -ne $null -and $ctrl.Visible)
                {
                    $col = @()
                    $col += $ctrl
                    $global:hpos += $ctrl.PreferredSize.Width + 5
                    $ctrl = Get-UIControl "help" $OtherAttributes["Help"] 0 "" @{NoNewLine=1}
                    $col += $ctrl
                    $ctrl = $col
                    $global:hpos = 22
                }
                elseif($OtherAttributes["NoNewLine"] -ne $null)
                {
                    $NoNewLine = $OtherAttributes["NoNewLine"]
                    $tmp = $ctrl | Select-Object -last 1
                    $global:hpos += $tmp.PreferredSize.Width + 5
                }
            }

            # Adjust height when long text is provided exceeding the height after text wrapping
            if(!$ctrl.AutoSize -and $size.Length -eq 1)
            {
                # Only width is specified and text is long
                $tmp = $ctrl | Select-Object -First 1
                $x = [Math]::ceiling($tmp.PreferredWidth / $tmp.Width) * $tmp.Font.height
                if($x -gt 0)
                {
                    $tmp.height = $x
                }
            }

            if(!$NoNewLine)
            {
                $tmp = $ctrl | Select-Object -First 1
                if($tmp.Visible)
                {
                    $global:vpos += $tmp.Height + 15
                }
            }
        }

        "link" {
            $ctrl = New-Object System.Windows.Forms.LinkLabel
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            if($Size.Count -gt 0 -and $Size[0] -gt 0)
            {
                $ctrl.Size = New-Object System.Drawing.Size($size[0], 30)
            }
            else
            {
                $ctrl.AutoSize = $true
            }
            if($value -ne $null)
            {
                if($OtherAttributes -ne $null -and $OtherAttributes["NoBrowserLaunch"] -ne $null)
                {}
                else
                {
                    $ctrl.add_LinkClicked({
                        #if($this.Links[0].LinkData -like "http*")
                        #{
                            Open-IETabs $([system.Environment]::ExpandEnvironmentVariables($this.Links[0].LinkData))
                        #}
                    })
                }

                $ctrl.Text = $value[0]
                $ctrl.Links.Add(0, $ctrl.Text.Length, $ctrl.Text) | Out-Null
            }

            if($OtherAttributes -ne $null)
            {
                $col = @()
                $col += $ctrl

                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "Bold" {
                            $oldFont = $ctrl.Font
                            $Font = New-Object System.Drawing.Font($oldFont.FontFamily,$oldFont.Size,[System.Drawing.FontStyle]::Bold)
                            $ctrl.Font = $Font
                        }

                        "Underline" {
                            $ctrl.LinkBehavior = [System.Windows.Forms.LinkBehavior]::NeverUnderline;
                        }

                        "UrlFormat" {
                            # re-add a link since there is no way to update
                            $ctrl.Links.Clear()
                            $tmp = $OtherAttributes["UrlFormat"] -f @($value)
                            $ctrl.Links.Add(0,$ctrl.Text.Length, $tmp) | Out-Null
                        }

                        "Help" {
                            Set-UITooltip $ctrl $OtherAttributes["Help"]
                        }

                        "Copy" {
                            If($ctrl.Visible -and $ctrl.Text -ne "")
                            {
                                if($size.Length -gt 1)
                                {
                                    $global:hpos += $ctrl.Width + 5
                                }
                                else
                                {
                                    $global:hpos += $ctrl.PreferredSize.Width + 5
                                }
                                $global:vpos = $ctrl.top
                                $col += $(Get-CopyButton)
                            }
                            $ctrl = $col
                        }

                        "NoNewLine" {
                            $NoNewLine = $OtherAttributes["NoNewLine"]
                            $global:hpos += $ctrl.PreferredSize.Width + 5
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }

                if($OtherAttributes["Text"] -ne $null)
                {
                    $ctrl.Text = $OtherAttributes["Text"]
                    $ctrl.Links[0].Length = $ctrl.Text.Length
                }
                else
                {
                    if($value -eq $null)
                    {
                        if($OtherAttributes["Default"] -ne $null)
                        {
                            $ctrl.Text = $OtherAttributes["Default"]
                            if($OtherAttributes["DefaultDisabled"])
                            {
                                $ctrl.Enabled = $false
                            }
                        }
                    }
                    else
                    {
                        $ctrl.Tag = $Value -join ","

                        if($OtherAttributes["Format"] -ne $null)
                        {
                            if($OtherAttributes["Format"].EndsWith("[SIZE]") -and $(IsNumeric($value[0])))
                            {
                                $ctrl.Text = Format-SizeWithUnit $value[0] $OtherAttributes["Format"]
                            }
                            elseif($OtherAttributes["Format"].indexOf("[AGE]") -ne -1 -and $($value[0] -is [datetime]))
                            {
                                $ctrl.Text = Format-AgeWithUnit $value[0] $OtherAttributes["Format"]
                            }
                            else
                            {
                                $ctrl.Text = $OtherAttributes["Format"] -f @($value)
                            }
                            $ctrl.Links[0].Length = $ctrl.Text.Length
                        }
                        else
                        {
                            $strValue = $value[0].ToString()
                            if($OtherAttributes["Instr"] -ne $null)
                            {
                                $arr = $OtherAttributes["Instr"].split(",")
                                if($arr.Length -eq 0)
                                {
                                    $strValue = Get-Instr $strValue $arr[0]
                                }
                                else
                                {
                                    $strValue = Get-Instr $strValue $arr[0] $arr[1]
                                }
                            }

                            if($OtherAttributes["Replace"] -ne $null)
                            {
                                $arr = $OtherAttributes["Replace"].split(",")
                                $strValue = $strValue.Replace($arr[0],$arr[1])
                            }

                            $ctrl.Text = $strValue
                            $ctrl.Links[0].Length = $ctrl.Text.Length
                        }
                    }
                }

                $ctrl = $col
            }

            if($value -ne $null)
            {
                if($ctrl.Count -gt 1)
                {
                    $c = $ctrl[0]
                }
                else
                {
                    $c = $ctrl
                }
                if($c.Text -eq "")
                {
                    $c.Text = $value[0]
                }
                If($OtherAttributes -ne $null -and $OtherAttributes["Help"] -eq $null -and $value[0] -Like "http*")
                {
                    Set-UITooltip $c $value[0]
                }
            }

            if(!$NoNewLine)
            {
                $global:vpos += 35
            }
        }

        "listview" {
            $ctrl = New-Object System.Windows.Forms.ListView
            $ctrl.FullRowSelect = $true
            $ctrl.HideSelection = $false
            $ctrl.AllowColumnReorder = $true
            $ctrl.GridLines = $true
            $ctrl.View = "Details"   # LargeIcon[default], SmallIcon, Tile, List
            $ctrl.BorderStyle = [System.Windows.Forms.BorderStyle]::None
            #$ctrl.BackColor = "Transparent"
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)

            $ctrl.Add_KeyDown({
                if($_.Modifiers -eq [System.Windows.Forms.Keys]::Control -And $_.KeyCode -eq [System.Windows.Forms.Keys]::C)
                {
                    $txt = ""
                    $this.SelectedItems | ForEach-Object {
                        $_.subItems | ForEach-Object {
                            $txt = $txt + $_.Text + "`t"
                        }
                        $txt += $_.Text + "`r`n"
                    }
                    if($txt -ne "")
                    {
                        [Windows.Forms.Clipboard]::SetText($txt)
                    }
                }
            })

            $props = New-Object System.Collections.ArrayList
            $i = 1
            $allWidth = 25  # Extra space to avoid horizontal scrollbar
            if($value -ne $null)
            {
                # File Explorer?
                if($OtherAttributes -ne $null -and $OtherAttributes["FileExplorer"] -ne $null)
                {
                    $ctrl.tag = $value[0]
                    $arr = $OtherAttributes["FileExplorer"] -split ","
                    switch($arr[0])
                    {
                        "D" {
                            $value = Get-ChildItem -path "$value" | Where-Object {$_.PSIsContainer} | Select-Object Name, LastWriteTime, Length, @{Name='Type';Expression={if($_ -is [System.IO.DirectoryInfo]){"D"}else{[System.IO.Path]::GetExtension($_).TrimStart(".")}}}, FullName
                         }
                        "F" {
                            $value = Get-ChildItem -path "$value" | Where-Object {!$_.PSIsContainer} | Select-Object Name, LastWriteTime, Length, @{Name='Type';Expression={if($_ -is [System.IO.DirectoryInfo]){"D"}else{[System.IO.Path]::GetExtension($_).TrimStart(".")}}}, FullName
                        }
                        default {
                            $value = Get-ChildItem -path "$value" | Select-Object Name, LastWriteTime, Length, @{Name='Type';Expression={if($_ -is [System.IO.DirectoryInfo]){"D"}else{[System.IO.Path]::GetExtension($_).TrimStart(".")}}}, FullName
                        }
                    }
                    if($arr.Count -gt 1)
                    {
                        if($arr[1][0] -eq "*")
                        {
                            $value = $value | Sort-Object $($arr[1].subString(1)) -Descending
                        }
                        else
                        {
                            $value = $value | Sort-Object $($arr[1])
                        }
                    }
                    if($Size.Count -eq 0)
                    {
                        $size = 300,130,-80
                    }
                    if($arr[0] -ne "D" -and $arr[0] -ne "F")
                    {
                        $ctrl.Add_DoubleClick({
                            $intColumn = GetListViewSubItemIndex $this "Type"
                            if($this.SelectedItems[0].SubItems[$intColumn].Text -eq "D")
                            {
                                $col = @()
                                if($this.SelectedItems[0].Text -eq "..")
                                {
                                    $CurrentPath = Get-Instr $this.Tag "" "-\"
                                }
                                else
                                {
                                    $CurrentPath = ("{0}\{1}" -f $this.Tag,$this.SelectedItems[0].Text)
                                    $pfobject = New-Object -TypeName PSObject -Property @{
                                        Name = ".."
                                        Type = "D"
                                    }
                                    $col += $pfobject
                                }

                                $col2 = Get-ChildItem -path $CurrentPath | Select-Object Name, LastWriteTime, Length, @{Name='Type';Expression={if($_ -is [System.IO.DirectoryInfo]){"D"}else{[System.IO.Path]::GetExtension($_).TrimStart(".")}}}
                                $col += $col2

                                Refresh-ListViewContents $this $col
                                $this.tag = $CurrentPath
                            }
                        })
                    }
                }

                # Set ListView Columns
                Switch($value[0].GetType().Name)
                {
                    {($_ -eq "HashTable") -or ($_ -eq "SPPropertyBag") -or ($_ -eq 'Dictionary`2')} {
                        $subWidth = 120
                        if($Size.Count -gt 0 -and $size[0] -gt 0)
                        {
                            $subWidth= $size[0]
                        }
                        $allWidth += $subWidth
                        $ctrl.Columns.Add("Key", $subWidth) | Out-Null

                        $subWidth = 120
                        if($size.Count -gt 1)
                        {
                            $subWidth= $size[1]
                        }
                        $allWidth += $subWidth
                        $ctrl.Columns.Add("Value", $subWidth) | Out-Null
                    }
                    "String" { # just string array
                        $subWidth = 120
                        if($Size.Count -gt 0 -and $size[0] -gt 0)
                        {
                            $subWidth= $size[0]
                        }
                        $allWidth += $subWidth
                        $ctrl.Columns.Add("Value", $subWidth) | Out-Null
                    }
                    default {
                        if($OtherAttributes -ne $null -and $OtherAttributes["Elements"] -ne $null)
                        {
                            #ex: ColName1,ColName2,...
                            $arrElements = $OtherAttributes["Elements"] -split ","
                            $arrElements | ForEach-Object {
                                $subWidth = 120
                                if($size.count -eq 1 -and $size[0] -eq 0)
                                {}
                                elseif($size.Count -ge $i) # -and $size[0] -ne 0)
                                {
                                    if($size[$i-1] -lt 0)
                                    {
                                        $subWidth= -1 * $size[$i-1]
                                        $blnRightCol = $true
                                    }
                                    else
                                    {
                                        $subWidth= $size[$i-1]
                                    }
                                }
                                $allWidth += $subWidth

                                $arrElement = $_.split("|")
                                if($arrElement.Length -gt 1)
                                {
                                    $strHeader = $arrElement[1]
                                    $blnAddTag = $true
                                }
                                else
                                {
                                    $strHeader = $arrElement[0]
                                    $blnAddTag = $false
                                }

                                if($arrElement[0] -eq "Name")
                                {
                                    $tmp = $ctrl.Columns.Insert(0, $strHeader, $subWidth)
                                    $props.Insert(0,$arrElement[0]) | Out-Null
                                }
                                else
                                {
                                    #$tmp = $ctrl.Columns.Add($_, $subWidth)
                                    $tmp = $ctrl.Columns.Add($strHeader, $subWidth)
                                    $props.Add($arrElement[0]) | Out-Null
                                }

                                if($blnAddTag)
                                {
                                    $tmp.tag += "OrigColName=$($arrElement[0]);"
                                }

                                if($blnRightCol)
                                {
                                    $tmp.TextAlign = "Right"
                                }
                                $i++
                            }
                        }
                        else
                        {
                            $blnDataSet = $false
                            $value[0] | ForEach-Object {$_.PSObject.Properties} | ForEach-Object {
                                if(!$blnDataSet -and $_.Name -eq "RowError")
                                {
                                    # determine if it is a dataset so that the last 5 fields are skipped (RowError, RowState, Table, ItemArray, HasErrors)
                                    if($($Value[0].PSObject.Properties | Select-Object -last 1 | Select-Object -expandproperty name) -eq "HasErrors")
                                    {
                                        $blnDataSet = $true
                                    }
                                }

                                if(!$blnDataSet)
                                {
                                    $blnRightCol = $false

                                    $subWidth = 120
                                    if($size.count -eq 1 -and $size[0] -eq 0)
                                    {}
                                    elseif($size.Count -ge $i) # -and $size[0] -ne 0)
                                    {
                                        if($size[$i-1] -lt 0)
                                        {
                                            $subWidth= -1 * $size[$i-1]
                                            $blnRightCol = $true
                                        }
                                        else
                                        {
                                            $subWidth= $size[$i-1]
                                        }
                                    }
                                    $allWidth += $subWidth

                                    ####if($strCol -eq "Name")
                                    if($_.Name -eq "Name")
                                    {
                                        $tmp = $ctrl.Columns.Insert(0,"Name", $subWidth) | Out-Null
                                        $props.Insert(0,"Name") | Out-Null
                                    }
                                    else
                                    {
                                        $tmp = $ctrl.Columns.Add($_.Name, $subWidth)
                                        if($_.TypeNameOfValue -eq "System.Int32")
                                        {
                                            $blnRightCol = $true
                                        }
                                        $props.Add($_.Name) | Out-Null
                                    }

                                    if($blnRightCol)
                                    {
                                        $tmp.TextAlign = "Right"
                                    }
                                    $i++
                                }
                            }
                        }
                    }
                }
                $ctrl.Columns.Add("*", 22) | Out-Null

                if($value.Count)
                {
                    if($value[0].GetType().Name -eq "HashTable" -or $value[0].GetType().Name -eq "SPPropertyBag" -or $value[0].GetType().Name -eq 'Dictionary`2')
                    {
                        $allHeight = ($value[0].Count+2)*17
                    }
                    else
                    {
                        $allHeight = ($value.Count+2)*17
                    }
                }
                else
                {
                    $allHeight = 50
                }
                if(!$(IsISE)) { $allWidth += 15;$allHeight+=2 }
                $ctrl.Size = New-Object System.Drawing.Size($allWidth, $allHeight)

                Switch($value[0].GetType().Name)
                {
                    {($_ -eq "HashTable") -or ($_ -eq "SPPropertyBag") -or ($_ -eq 'Dictionary`2')} {
                        $i = 0
                        $value[0].Keys | ForEach-Object {
                            $tmp = $ctrl.Items.Add($_)
                            if($value[0][$_] -eq $null)
                            {
                                $tmp.SubItems.Add("") | Out-Null
                            }
                            else
                            {
                                $tmp.SubItems.Add($value[0][$_].ToString()) | Out-Null
                            }

                            if($OtherAttributes["AlternatingColor"] -ne $null -and ($i % 2) -eq 1)
                            {
                                $tmp.BackColor = $OtherAttributes["AlternatingColor"]
                            }
                            $i++
                        }
                    }
                    "String" { # just string array
                        $value | ForEach-Object {
                            $tmp = $ctrl.Items.Add($_)
                        }
                    }
                    default {
                        $iconfld = "IconType"
                        if($OtherAttributes -ne $null -and $OtherAttributes["IconLocator"] -ne $null)
                        {
                            $iconfld = $OtherAttributes["IconLocator"]
                        }

                        $i = 0
                        $value | ForEach-Object {
                            $element = $_
                            if($element -ne $null -and $element.gettype().Name -like "SPAcl*") {
                                $element = $element[0]
                            }   #weird datatype
                            $blnName = $true
                            $props | ForEach-Object {
                                if($blnName)
                                {
                                    if($element.$_ -eq $null)
                                    {
                                        $tmp = $ctrl.Items.Add("")
                                    }
                                    else
                                    {
                                        $tmp = $ctrl.Items.Add($element.$_.ToString(), $element.$_.ToString(),0)
                                    }

                                    if($element.$iconfld -eq $null -or $element.$iconfld -eq [DBNull]::Value)
                                    {}
                                    else
                                    {
                                        if($OtherAttributes["IconElements"] -eq $null)
                                        {
                                            $sctrl = $ctrl.SmallImageList
                                            if($sctrl -eq $null)
                                            {
                                                $sctrl = New-Object System.Windows.Forms.ImageList
                                                $sctrl.ImageSize = New-Object System.Drawing.Size(16,16)
                                                $ctrl.SmallImageList = $sctrl
                                            }
                                            $imgFileName = "$env:dp\Assets\{0}" -f $element.$iconfld

                                            # Skip image insertion if key exists
                                            if($sctrl.images.ContainsKey($element.$iconfld))
                                            {
                                                $tmp.ImageKey = $element.$iconfld
                                            }
                                            elseif(Test-Path $imgFileName)
                                            {
                                                $item = Get-ImagefromFile $imgFileName
                                                $sctrl.Images.Add($element.$iconfld,$item)
                                                $tmp.ImageKey = $element.$iconfld
                                            }
                                        }
                                        else
                                        {
                                            $imgvalue = $element.$iconfld
                                            if($(isNumeric($imgvalue.ToString())))
                                            {
                                                $tmp.ImageIndex = $imgvalue
                                            }
                                            else
                                            {
                                                $tmp.ImageKey=$imgvalue.ToString()
                                            }
                                        }
                                    }
                                    $blnName = $false
                                }
                                else
                                {
                                    if($element.$_ -ne $null)
                                    {
                                        $subItem = $tmp.SubItems.Add($element.$_.ToString())
                                        if($OtherAttributes -ne $null)
                                        {
                                            if($OtherAttributes["TextTransform"] -ne $null)
                                            {
                                                $arrFlds = $OtherAttributes["TextTransform"].Split("][")
                                                Foreach($fld in $arrFlds)
                                                {
                                                    $arrTRS = $fld.split("~")
                                                    if($_ -eq $arrTRS[0])
                                                    {
                                                        $arrTR = $arrTRS[1] -split ","
                                                        ForEach($txt in $arrTR)
                                                        {
                                                            if($txt.Contains("|"))
                                                            {
                                                                $arrT = $txt.split("|")
                                                                if($arrT[0] -eq $subItem.Text)
                                                                {
                                                                    $subItem.Tag = $subItem.Text
                                                                    $subItem.Text = $arrT[1]
                                                                    break
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            if($OtherAttributes["TextStyle"] -ne $null)
                                            {
                                                if($OtherAttributes["TextStyle"] -ne $null)
                                                {
                                                    $arrFlds = $OtherAttributes["TextStyle"].Split("][")
                                                    Foreach($fld in $arrFlds)
                                                    {
                                                        if($fld -ne "")
                                                        {
                                                            $styleRow = $false
                                                            $arrTSS = $fld -split "~"
                                                            if($arrTSS[0].StartsWith("*"))
                                                            {
                                                                $styleRow = $true
                                                                $arrTSS[0] = $arrTSS[0].Substring(1)
                                                            }
                                                            else
                                                            {
                                                                $tmp.UseItemStyleForSubItems = $false
                                                            }
                                                            if($_ -eq $arrTSS[0])
                                                            {
                                                                For($i=1;$i -lt $arrTSS.Length;$i++)
                                                                {
                                                                    $arrTS = $arrTSS[$i].split(",")
                                                                    # $arrTS[0] is for evaluation
                                                                    # $arrTS[1] should have 5 segments - forecolor|backcolor|font|size|style
                                                                    $blnEval = $null
                                                                    if($arrTS[0].Contains('{0}'))
                                                                    {
                                                                        if(IsNumeric($subItem.Text))
                                                                        {
                                                                            #numeric
                                                                            $blnEval = Invoke-Expression $($arrTS[0] -f $subItem.Text)
                                                                        }
                                                                        elseif(IsDate($subItem.Text))
                                                                        {
                                                                            #datetime   #TODO
                                                                            $blnEval = Invoke-Expression $($arrTS[0] -f $subItem.Text)
                                                                        }
                                                                    }
                                                                    if($blnEval -eq $null)
                                                                    {
                                                                        #bool, text
                                                                        $blnEval = $($arrTS[0] -eq $subItem.Text)
                                                                    }

                                                                    if($blnEval)
                                                                    {
                                                                        $arrT = $arrTS[1].split("|")
                                                                        $newfont = $false
                                                                        $fontName = $subitem.Font.Name
                                                                        $fontSize = $subitem.Font.Size
                                                                        $fontStyle = $subitem.Font.Style
                                                                        if($arrT[0].Trim() -ne "")
                                                                        {
                                                                            if($styleRow)
                                                                            {
                                                                                $tmp.ForeColor = $arrT[0]
                                                                            }
                                                                            else
                                                                            {
                                                                                $subItem.ForeColor = $arrT[0]
                                                                            }
                                                                        }
                                                                        if($arrT.Length -gt 1 -and $arrT[1].Trim() -ne "")
                                                                        {
                                                                            if($styleRow)
                                                                            {
                                                                                $tmp.BackColor = $arrT[1]
                                                                            }
                                                                            else
                                                                            {
                                                                                $subItem.BackColor = $arrT[1]
                                                                            }
                                                                        }
                                                                        if($arrT.Length -gt 2 -and $arrT[2].Trim() -ne "")
                                                                        {
                                                                            $fontName = $arrT[2]
                                                                            $newfont = $true
                                                                        }
                                                                        if($arrT.Length -gt 3 -and $arrT[3].Trim() -ne "")
                                                                        {
                                                                            $fontSize = $arrT[3]
                                                                            $newfont = $true
                                                                        }
                                                                        if($arrT.Length -gt 4 -and $arrT[4].Trim() -ne "")
                                                                        {
                                                                            if($arrT[4].Contains("B")) {$fontStyle = [System.Drawing.FontStyle]($fontStyle -bor [System.Drawing.FontStyle]::Bold)}
                                                                            if($arrT[4].Contains("I")) {$fontStyle = [System.Drawing.FontStyle]($fontStyle -bor [System.Drawing.FontStyle]::Italic)}
                                                                            if($arrT[4].Contains("S")) {$fontStyle = [System.Drawing.FontStyle]($fontStyle -bor [System.Drawing.FontStyle]::Strikeout)}
                                                                            if($arrT[4].Contains("U")) {$fontStyle = [System.Drawing.FontStyle]($fontStyle -bor [System.Drawing.FontStyle]::Underline)}
                                                                            $newfont = $true
                                                                        }
                                                                        if($newfont)
                                                                        {
                                                                            $subitem.Font = new-object System.Drawing.font($fontName, $fontSize, $fontStyle)
                                                                        }
                                                                        break
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        # custom styling and text transformation
                                        #$hello.tag = $hello.Text
                                        #$hello.ForeColor = "red"
                                        #$hello.Font = new-object System.Drawing.font("WingDings", 12, [System.Drawing.FontStyle]::Regular)
                                        #$hello.Text = [char]252
                                    }
                                    else
                                    {
                                        #write "" for null
                                        $tmp.SubItems.Add("") | Out-Null
                                    }
                                }
                                if($OtherAttributes -ne $null -and $OtherAttributes["ToolTip"] -ne $null -and $_ -eq $OtherAttributes["ToolTip"] -and $element.$_ -ne $null)
                                {
                                    $tmp.TooltipText = $element.$_.ToString()
                                }
                            }

                            if($OtherAttributes -ne $null -and $OtherAttributes["AlternatingColor"] -ne $null -and ($i % 2) -eq 1)
                            {
                                $tmp.BackColor = $OtherAttributes["AlternatingColor"]
                            }
                            $i++
                        }
                    }
                }
            }

            $ctrl.Add_ColumnClick({
<#				$this.ListViewItemSorter = New-Object ListViewItemComparer($_.Column)
                $this.Sort()  #this old one has bugs and supports ascending sort only#>

                if($_.Column -lt $($this.Columns.Count-1))
                {
                    if($this.ListViewItemSorter -eq $null)
                    {
                        $this.ListViewItemSorter = New-Object ListViewColumnSorter
                    }
                    if ( $_.Column -eq $this.ListViewItemSorter.SortColumn )
                    {
                        if ($this.ListViewItemSorter.Order -eq [System.Windows.Forms.SortOrder]::Ascending)
                        {
                            $this.ListViewItemSorter.Order = [System.Windows.Forms.SortOrder]::Descending
                        }
                        else
                        {
                            $this.ListViewItemSorter.Order = [System.Windows.Forms.SortOrder]::Ascending
                        }
                    }
                    else
                    {
                        $this.ListViewItemSorter.SortColumn = $_.Column
                        $this.ListViewItemSorter.Order = [System.Windows.Forms.SortOrder]::Ascending
                    }
                    $this.Sort();
                }
                else
                {
                    $form2 = Get-UIWinForm "Toggle Column Visibility" "" "OK","Close" 220 200
                    $AllColumns = ($this.columns | Where-Object {$_.Text -ne "*"} | Select-Object -ExpandProperty Text)  -join ","
                    $VisibleColumns = $this.columns | Where-Object {$_.Text -ne "*" -and $_.Width -gt 0} | Select-Object -ExpandProperty Text
                    $ctrl = Get-UIControl "checklistbox" $VisibleColumns 180,140 "edit" @{Name="clbColumn";Elements=$AllColumns}
                    $form2.Controls.Add($ctrl)

                    $btnOK = $form2.Controls.Find("btnOK",$true)[0]
                    if($btnOK -ne $null)
                    {
                        $btnOK.Add_Click({
                            $clbColumn = $this.FindForm().Controls.Find("clbColumn", $true)[0]
                            $this.FindForm().Tag = $clbColumn.CheckedItems -join ","
                        })
                    }
                    $form2.ShowDialog() | Out-Null
                    if($form2.DialogResult -eq [System.Windows.Forms.DialogResult]::OK)
                    {
                        $arr = $form2.tag.split(",")
                        #Set column's visibility
                        $this.columns | ForEach-Object {
                            if($_.Text -ne "*")
                            {
                                if($arr -NotContains $_.Text)
                                {
                                    $_.tag =  $_.Width
                                    $_.Width = 0
                                }
                                else
                                {
                                    # Visible columns
                                    if($_.Width -eq 0)
                                    {
                                        if($_.tag -ne $null)
                                        {
                                            $_.Width = $_.tag
                                            $_.tag = $null
                                        }
                                        else
                                        {
                                            $_.Width = -1
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })

            if($OtherAttributes -ne $null)
            {
                if($OtherAttributes["Backcolor"] -ne $null)
                {
                    $ctrl.BackColor = $OtherAttributes["backcolor"]
                }

                if($OtherAttributes["HotTracking"] -ne $null)
                {
                    $ctrl.HotTracking = $OtherAttributes["HotTracking"]
                }

                if($OtherAttributes["HeaderStyle"] -ne $null)
                {
                    # Clickable, Nonclickable, None (hide it)
                    $ctrl.HeaderStyle = $OtherAttributes["HeaderStyle"]
                }

                if($OtherAttributes["Tooltip"] -ne $null)
                {
                    $ctrl.ShowItemTooltips = $true
                }

                if($OtherAttributes["Name"] -ne $null)
                {
                    $ctrl.Name = $OtherAttributes["Name"]
                }

                if($OtherAttributes["GroupElement"] -ne $null)
                {
                    $tmp = GroupListView $ctrl $OtherAttributes["GroupElement"]
                    if($tmp -and $allHeight -gt 0)
                    {
                        $ctrl.Height += $ctrl.Groups.Count * 47
                    }
                }

                if($OtherAttributes["IconElements"] -ne $null)
                {
                    if($OtherAttributes["IconElements"] -is [System.Windows.Forms.ImageList])
                    {
                        $ctrl.SmallImageList = $OtherAttributes["IconElements"]
                    }
                    else
                    {
                        $sctrl = New-Object System.Windows.Forms.ImageList
                        $sctrl.ImageSize = New-Object System.Drawing.Size(16,16)
                        if($OtherAttributes["IconSize"] -ne $null)
                        {
                            $intSize = [system.int32]::Parse($OtherAttributes["IconSize"])
                            $sctrl.ImageSize = New-Object System.Drawing.Size($intSize, $intSize)
                        }

                        $OtherAttributes["IconElements"] -split "," | ForEach-Object {
                            if($_.Contains("|"))
                            {
                                $arr = $_.split("|")
                                if(!$_.Contains("."))
                                {
                                    $arr[1] += ".png"
                                }
                                $item = Get-ImagefromFile $("$env:dp\Assets\{0}" -f $arr[1])
                                $sctrl.Images.Add($arr[0],$item)
                            }
                            else
                            {
                                if(!$_.Contains("."))
                                {
                                    $item = Get-ImagefromFile $("$env:dp\Assets\{0}.png" -f $_)
                                    $sctrl.Images.Add($_,$item)
                                }
                                else
                                {
                                    $key = $_.Substring(0,$_.IndexOf("."))
                                    $item = Get-ImageFromFile $("$env:dp\Assets\{0}" -f $_)
                                    $sctrl.Images.Add($key,$item)
                                }
                            }
                        }
                        $ctrl.SmallImageList = $sctrl
                    }
                }

                if($OtherAttributes["View"] -ne $null)
                {
                    $ctrl.View = $OtherAttributes["View"]  #LargeIcon (default), SmallIcon, List, Details, Tile
                    if($OtherAttributes["View"].Contains("Large"))
                    {
                        $ctrl.LargeImageList = $sctrl
                        $ctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
                    }
                    elseif($OtherAttributes["View"].Contains("Small"))
                    {
                        $ctrl.SmallImageList = $sctrl
                        $ctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
                    }
                }

                if($OtherAttributes["Checkboxes"] -ne $null)
                {
                    if($OtherAttributes["Checkboxes"] -ge "1")
                    {
                        $ctrl.Checkboxes = $OtherAttributes["Checkboxes"]
                    }

                    $blnDefaultCheck = ($OtherAttributes["Checkboxes"] -eq "2")

                    # Set default checked status to all items
                    if($blnDefaultCheck)
                    {
                        $ctrl.Items | ForEach-Object {
                            $_.Checked = $blnDefaultCheck
                        }
                    }

                    $col = @()
                    $col+= $ctrl
                    $tmp = Get-UIControl CheckBox $blnDefaultCheck 0 "edit"
                    $tmp.Location = New-Object System.Drawing.Point($($ctrl.Left + 3), $ctrl.Top)
                    $tmp.Add_CheckedChanged({
                        $idx = $this.Parent.Controls.IndexOf($this)-1
                        $tmp = [System.Windows.Forms.ListView]$this.Parent.Controls[$idx]
                        if($tmp -ne $null)
                        {
                            $tmp.Items | ForEach-Object {
                                $_.Checked = $this.Checked
                            }
                        }
                    })
                    $ctrl.Top += 15
                    $global:vpos += 15
                    $col += $tmp
                    $ctrl = $col
                }

                if($OtherAttributes["Footer"] -ne $null)
                {
                    $col = @()

                    $arr = $OtherAttributes["Footer"].Split(",")
                    if($arr.Length -eq 1)
                    {
                        $footervalue = $ctrl.Items.Count
                    }
                    else
                    {
                        $footervalue = GetListViewComputedValue $ctrl $arr[1]
                    }
                    $col+= $ctrl

                    $ctrl = New-Object System.Windows.Forms.Label
                    $ctrl.BackColor = "Black"
                    $ctrl.ForeColor = "White"
                    $ctrl.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
                    $ctrl.Width = $allWidth
                    $ctrl.Height = 17
                    $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $($global:vpos+$allHeight+1))

                    if($OtherAttributes["Footer"].StartsWith(">"))
                    {
                        $ctrl.TextAlign = "MiddleRight"
                        $OtherAttributes["Footer"] = $OtherAttributes["Footer"].Substring(1)
                    }
                    $ctrl.Text =  $arr[0] -f $footervalue
                    $col += $ctrl
                    $global:vpos += 17
                    $ctrl = $col
                }

                if($OtherAttributes["NoNewLine"] -ne $null)
                {
                    $NoNewLine = $OtherAttributes["NoNewLine"]
                    $global:hpos += $ctrl.Width + 5
                }
            }

            if(!$NoNewLine)
            {
                 $global:vpos += $allHeight + 15
            }
        }

        "menu" {
            if($OtherAttributes -ne $null)
            {
                if($OtherAttributes["Elements"] -ne $null)
                {
                    if($OtherAttributes["Elements"].StartsWith("<"))
                    {
                        Try
                        {
                            $layouts = [xml]$OtherAttributes["Elements"]
                            $layouts = Select-Xml -Xml $layouts -Xpath "//Layout"
                        }
                        Catch {}
                    }
                    elseif($global:configXml.Root.Elements -ne $null)
                    {
                        if($OtherAttributes["Elements"].IndexOf(",") -ne -1)
                        {
                            $arr = $OtherAttributes["Elements"].Split(',')
                            $strXpath = "Element[ID='{0}']/Layouts/Layout[@Filter='{1}']" -f $arr[0], $arr[1]
                        }
                        else
                        {
                            $strXpath = "Element[ID='{0}']/Layouts/Layout" -f $OtherAttributes["Elements"]
                        }
                        $layouts = select-xml -xml $($global:configXml.Root.Elements) -xpath $strXpath
                    }
                }
            }

            if($layouts -ne $null)
            {
                # set value[0] to the first one if not passed
                if($value.count -gt 0 -and [System.String]::IsNullOrEmpty($value[0]))
                {
                    if($layouts.count -eq $null)
                    {
                        $value = $layouts.Node.ID
                    }
                    else
                    {
                        $value = $layouts[0].Node.ID
                    }
                }

                $ctrl = New-Object System.Windows.Forms.MenuStrip
                $ctrl.LayoutStyle = [System.Windows.Forms.ToolStripLayoutStyle]::Flow
                $layouts | ForEach-Object {
                    $menu = New-Object System.Windows.Forms.ToolStripMenuItem
                    IF($_.Node.Text -ne $null)
                    {
                        $menu.Text = $_.Node.Text
                    }
                    else
                    {
                        $menu.Text = $_.Node.ID
                    }
                    $menu.Name= $_.Node.ID   #key
                    #$menu.Tag = $OtherAttributes["Elements"]   ~~Let me use tag to store enabled/visible
                    if($_.Node.GetAttribute("Help") -ne "")
                    {
                        $menu.ToolTipText = $_.Node.GetAttribute("Help")
                        $ctrl.ShowItemTooltips = $true
                    }

                    if($_.Node.GetAttribute("Enable") -ne "")
                    {
                        $menu.tag = $_.Node.GetAttribute("Enable")
                    }

                    if($_.Node.GetAttribute("Visible") -ne "")
                    {
                        $menu.tag = $_.Node.GetAttribute("Visible")
                    }

                    # Store the selected item in Tag property
                    if($value -ne $null -and $_.Node.ID -eq $value[0])
                    {
                        $menu.ForeColor = "Blue"
                        $ctrl.tag = $_.Node.ID
                    }
                    $ctrl.Items.Add($menu) | Out-Null
                    if($_.Node.Sublayout -ne  $null)
                    {
                        $_.Node.Sublayout | ForEach-Object {
                            $submenu = New-Object System.Windows.Forms.ToolStripMenuItem
                            IF($_.Text -ne $null)
                            {
                                $submenu.Text = $_.Text
                            }
                            else
                            {
                                $submenu.Text = $_.ID
                            }
                            $submenu.Name= $_.ID   #key
                            if($_.GetAttribute("Help") -ne "")
                            {
                                $submenu.ToolTipText = $_.GetAttribute("Help")
                                $ctrl.ShowItemTooltips = $true
                            }
                            $menu.DropDownItems.Add($submenu) | Out-Null
                        }
                    }
                }

                if($OtherAttributes -ne $null)
                {
                    $col = @()
                    $col += $ctrl

                    foreach($key in $OtherAttributes.Keys)
                    {
                        switch($key)
                        {
                            default {
                                try {
                                    $ctrl.$($key) = $OtherAttributes[$key]
                                }
                                catch {

                                }
                            }
                        }
                    }

                    $ctrl = $col
                }
            }
        }

        "monthcalendar" {
            $ctrl = New-Object System.Windows.Forms.MonthCalendar
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)

            if($value -ne $null)
            {
                $ctrl.Text = [DateTime]$value[0]
            }

            if($mode -eq "view")
            {
                $ctrl.Enabled = $false
            }

            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "MaxDate" {
                            if(isNumeric($OtherAttributes["MaxDate"]))
                            {
                                $ctrl.MaxDate = [System.DateTime]::Today.AddDays([System.Int32]::Parse($OtherAttributes["MaxDate"]))
                            }
                            else
                            {
                                $ctrl.MaxDate = [DateTime]::Parse($OtherAttributes["MaxDate"])
                            }
                        }

                        "MinDate" {
                            if(isNumeric($OtherAttributes["MinDate"]))
                            {
                                $ctrl.MinDate = [System.DateTime]::Today.AddDays([System.Int32]::Parse($OtherAttributes["MinDate"]))
                            }
                            else
                            {
                                $ctrl.MinDate = [DateTime]::Parse($OtherAttributes["MinDate"])
                            }
                        }

                        "NoNewLine" {
                            $NoNewLine = $OtherAttributes["NoNewLine"]
                            $global:hpos += $ctrl.Width + 5
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }
            }

            if(!$NoNewLine)
            {
                 $global:vpos += 180
            }
        }

        "panel" {
            $ctrl = New-Object System.Windows.Forms.Panel
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            if($size -ne $null -and $size.Count -eq 2)
            {
                 $ctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
            }
            else
            {
                $ctrl.AutoSize = $true
                $ctrl.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowOnly
            }
            if($value -ne $null)
            {
                $ctrl.Text = $value[0]
            }
            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }
            }
        }

        "progressbar" {
            $ctrl= New-Object System.Windows.Forms.ProgressBar
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            if($size -eq $null -or $size[0] -eq 0)	   # default 300 pixel if width is not provided
            {
                $ctrl.Width=300
            }
            else
            {
                $ctrl.Size = New-Object System.Drawing.Size($size[0], 20)
            }
            $ctrl.Value = $value[0]
            if($value.count -gt 1)
            {
                $ctrl.Maximum = $value[1]
            }
            else
            {
                $ctrl.Maximum = 100
            }

            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "color" {   # "0|Green,50|Yellow,80|Red"
                            $ctrl.Style= [System.Windows.Forms.ProgressBarStyle]::Continuous
                            if($OtherAttributes["Color"].indexOf(",") -eq -1)
                            {
                                $ctrl.ForeColor = $OtherAttributes["Color"]
                            }
                            else
                            {
                                $tmp = ($value[0]/$value[1]) * 100
                                $OtherAttributes["Elements"] -split "," | ForEach-Object {
                                    $val = [system.int32]::Parse($arr[0])
                                    if($tmp -ge $val)
                                    {
                                        $ctrl.ForeColor = $arr[1]
                                    }
                                }
                            }
                        }

                        "Label" {
                            $col = @()
                            $col += $ctrl
                            if($ctrl.AutoSize)
                            {
                                $global:hpos += $ctrl.PreferredSize.Width
                            }
                            else
                            {
                                $global:hpos += $ctrl.Width + 5
                            }
                            $ctrl = Get-UIControl label ($OtherAttributes["Label"] -f $value[0], $value[1]) 0 "" @{NoNewLine=1}
                            $col += $ctrl
                            $ctrl = $col
                        }

                        "Help" {
                            $col = @()
                            $col += $ctrl
                            $lastCtrl = $ctrl | Select-Object -Last 1
                            $global:hpos = $lastCtrl.Left + $lastctrl.PreferredSize.Width + 5
                                $ctrl = Get-UIControl "help" $OtherAttributes["Help"] 0 "" @{NoNewLine=1}
                            $col += $ctrl
                            $ctrl = $col
                            $global:hpos = 22
                        }

                        "NoNewLine" {
                            $NoNewLine = $OtherAttributes["NoNewLine"]
                            $global:hpos += $ctrl.Width + 5
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }
            }

            if(!$NoNewLine)
            {
                 $global:vpos += 35
            }
            else
            {
                $global:hpos += $ctrl.PreferredSize.Width + 5
            }
        }

        "richtextbox" {
            $ctrl = New-Object System.Windows.Forms.RichTextBox
            #$ctrl.DetectUrls = $true   this is default
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            if($global:hpos -eq 0 -and $global:vpos -eq 0)
            {
                $ctrl.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
                               [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
            }
            if($size -eq $null -or $size[0] -eq 0)	   # default 100 pixel if width is not provided
            {
                $ctrl.Width=100
            }
            else
            {
                if($size.Length -gt 1)
                {
                    $ctrl.Multiline = $true
                    $ctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
                    $global:vpos += $size[1]
                }
                else
                {
                    $ctrl.Size = New-Object System.Drawing.Size($size[0], 30)
                }
            }
            if($value -ne $null)
            {
                #$ctrl.AppendText($value[0])
                if($value[0] -is [string])
                {
                    if ($value[0] -like "?:\*" -and $(Test-Path $value[0]))
                    {
                        try
                        {
                            if($value[0] -like "*.rtf")
                            {
                                $ctrl.Loadfile($value[0])
                            }
                            else
                            {
                                $ctrl.Loadfile($value[0], [System.Windows.Forms.RichTextBoxStreamType]::PlainText)
                            }
                        }
                        catch
                        {
                            $ctrl.Text = ("Error loading file '{0}' with message: {1}" -f $value[0], $_.Exception.Message)
                        }
                    }
                    else
                    {
                        $ctrl.Rtf = $value[0]
                    }
                }
                else
                {
                    $ctrl.Text = $value[0] | ConvertTo-json
                }
            }
            if($mode -eq "view")
            {
                $ctrl.ReadOnly = $true
            }
            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "ReadOnly" {
                            $ctrl.ReadOnly = $OtherAttributes["ReadOnly"]
                            if($ctrl.ReadOnly)
                            {
                                $ctrl.Backcolor = "gainsboro"
                            }
                            else
                            {
                                $ctrl.Backcolor = ""
                            }
                        }

                        "File" {
                           if($(test-path $OtherAttributes["File"]))
                            {
                                try
                                {
                                    $ctrl.Loadfile($OtherAttributes["File"])
                                }
                                catch
                                {
                                    $ctrl.Text = ("Error loading file '{0}' with message: {1}" -f $OtherAttributes["File"], $_.Exception.Message)
                                }
                            }
                            else  # .rtf not found
                            {
                                if($OtherAttributes["FileNotFound"] -eq $null)
                                {
                                    $ctrl.Text = ("File '{0}' Not Found" -f $OtherAttributes["File"])
                                }
                                else
                                {
                                    if($OtherAttributes["FileNotFound"] -eq "PROMPT")
                                    {
                                        if (Get-UIConfirmation ("Help file '{0}' doesn't exist.  Do you want to create a new one?" -f $OtherAttributes["File"]))
                                        {
                                            New-Item -ItemType File -Path $OtherAttributes["File"] | Out-Null
                                            Invoke-Expression $OtherAttributes["File"]
                                        }
                                    }
                                    else
                                    {
                                        $ctrl.Text = $OtherAttributes["FileNotFound"]
                                    }
                                }
                            }
                        }

                        "NoNewLine" {
                            $NoNewLine = $OtherAttributes["NoNewLine"]
                            $global:hpos += $ctrl.Width + 5
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }
            }

            if(!$NoNewLine)
            {
                $global:vpos += 20
            }
        }

        "slider" {
            $col = @()
            $ctrl= New-Object System.Windows.Forms.TrackBar
            $global:hpos -= 8
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            if($size -eq $null -or $size[0] -eq 0)	   # default 100 pixel if width is not provided
            {
                $size = 100
            }
            $ctrl.Size = New-Object System.Drawing.Size($($size[0]-30), 20)
            $ctrl.TickStyle = [System.Windows.Forms.TickStyle]::None
            $ctrl.Add_Scroll({
                $idx = $this.Parent.Controls.IndexOf($this)+1
                $tmp = [System.Windows.Forms.Label]$this.Parent.Controls[$idx]
                if($tmp -ne $null)
                {
                    $tmp.Text = $this.Value
                }
            })

            if($mode -eq "view")
            {
                $ctrl.Enabled = $false
            }

            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "NoNewLine" {
                            $NoNewLine = $OtherAttributes["NoNewLine"]
                            $global:hpos += $ctrl.Width + 5
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }
            }

            if($value -ne $null)
            {
                $ctrl.Value = $value[0]
            }
            $col+= $ctrl

            #$global:hpos += $($size[0]-30)
            $global:hpos += $ctrl.PreferredSize.Width + 5
            $ctrl = New-Object System.Windows.Forms.Label
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            $ctrl.TabStop = $false
            $ctrl.Text = $col[0].Maximum
            $ctrl.Width = $ctrl.PreferredSize.Width
            $ctrl.Text = $col[0].Value
            $col+= $ctrl

            if($OtherAttributes -ne $null)
            {
                if($OtherAttributes["Help"] -ne $null)
                {
                    $global:hpos += $ctrl.Width + 5
                    $ctrl = Get-UIControl "help" $OtherAttributes["Help"] 0 "" @{NoNewLine=1}
                    $col += $ctrl
                    $global:hpos = 22
                }
                elseif($OtherAttributes["NoNewLine"] -ne $null)
                {
                    $NoNewLine = $OtherAttributes["NoNewLine"]
                    $global:hpos += $ctrl.Width + 5
                }
            }
            $ctrl = $col

            if(!$NoNewLine)
            {
                $tmp = $ctrl | Select-Object -first 1
                if($tmp.Visible)
                {
                    $global:vpos += $tmp.Height
                }
            }
        }

        "tabcontrol" {
            $ctrl = New-Object System.Windows.Forms.TabControl
            $ctrl.Multiline = $true
            if($size[0] -eq 0)
            {
                if($global:vpos -eq 10 -and $global:hpos -eq 22)
                {
                    $ctrl.Location = New-Object System.Drawing.Point(5,5)
                }
                $ctrl.Dock = [System.Windows.Forms.DockStyle]::Fill
            }
            else
            {
                $ctrl.Width = $size[0]
            }
            if($size.Length -gt 1)
            {
                $ctrl.Height = $size[1]
            }

            $arrPageColor = $null
            $arrPageBackColor = $null
            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "PageColor" {
                            $arrPageColor = $OtherAttributes["Pagecolor"] -split ","
                        }

                        "PageBackcolor" {
                            $arrPageBackColor = $OtherAttributes["PageBackcolor"] -split ","
                        }

                        "Wizard" {
                            $ctrl.Tag = 0
                            $ctrl.Add_SelectedIndexChanged({
                                if($this.SelectedIndex -gt $this.tag)
                                {
                                    # prevent moving forward by simply clicking tab.  need code to set tag first in order to advance the tab
                                    $this.SelectedIndex = $this.tag
                                }
                                else
                                {
                                    $btnNext = $this.FindForm().Controls.Find("btnNext", $true)[0]
                                    if($btnNext -ne $null)
                                    {
                                        if($this.SelectedIndex -eq $($this.TabPages.Count-1))
                                        {
                                            $btnNext.Text = "Finish"
                                        }
                                        else
                                        {
                                            $btnNext.Text = "Next"
                                        }
                                    }
                                }
                            })
                        }

                        "IconElements" {
                            $sctrl = New-Object System.Windows.Forms.ImageList
                            $sctrl.ImageSize = New-Object System.Drawing.Size(24, 24);
                            $ctrl.ImageList = $sctrl

                            $OtherAttributes["IconElements"] -split "," | ForEach-Object {
                                $item = Get-ImageFromFile $_
                                $sctrl.Images.Add($item)
                                $i++
                            }
                        }

                        "Help" {
                            $arrHelp = $OtherAttributes["Help"] -split ","
                        }

                        "NoNewLine" {
                            $NoNewLine = $OtherAttributes["NoNewLine"]
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }

            }

            $i=0
            $value | ForEach-Object {
                $tabPage = New-Object System.Windows.Forms.TabPage
                if($arrPageColor -ne $null)
                {
                    if($arrPageColor.Count -gt $i)
                    {
                        $tabPage.ForeColor = $arrPageColor[$i]
                    }
                    else
                    {
                        $tabPage.ForeColor = $arrPageColor[0]
                    }
                }

                if($arrPageBackColor -ne $null)
                {
                    if($arrPageBackColor.Count -gt $i)
                    {
                        $tabPage.BackColor = $arrPageBackColor[$i]
                    }
                    else
                    {
                        $tabPage.BackColor = $arrPageBackColor[0]
                    }
                }

                if($arrHelp -ne $null)
                {
                    $ctrl.ShowToolTips = $true
                    if($arrHelp.Count -gt $i)
                    {
                        $tabPage.TooltipText= $arrHelp[$i]
                    }
                    else
                    {
                        $tabPage.TooltipText = $arrHelp[0]
                    }
                }

                $tabPage.Text = $_
                $tabPage.Name = $_
                $tabPage.ImageIndex = $i
                $tabPage.AutoScroll = $true
                #$tabPage.Padding = new-object System.Windows.Forms.Padding(25)
                $ctrl.Controls.Add($tabPage)
                $i++
            }
        }

        "textbox" {
            $ctrl = New-Object System.Windows.Forms.TextBox
            #$ctr.ShowFocusCues = $true
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            if($size -eq $null -or $size[0] -eq 0)	   # default 100 pixel if width is not provided
            {
                $ctrl.Width=100
            }
            else
            {
                # Right alignment
                if($size[0] -lt 0)
                {
                    $ctrl.TextAlign = "Right"
                    $size[0] = -1 * $size[0]
                }

                if($size.Length -gt 1)
                {
                    $ctrl.Multiline = $true
                    $ctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
                }
                else
                {
                    $ctrl.Size = New-Object System.Drawing.Size($size[0], 30)
                }
            }
            if($value -ne $null)
            {
                $ctrl.Text = $value[0]
            }
            if($mode -eq "view")
            {
                $ctrl.Enabled = $false
            }
            else
            {
                $ctrl.Add_GotFocus({
                    $this.SelectAll()
                })
            }

            if($OtherAttributes -ne $null)
            {
                $col = @()
                $col += $ctrl

                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "Copy" {
                            if($ctrl.Visible)
                            {
                                if($size.Length -gt 1)
                                {
                                    $global:hpos += $ctrl.Width + 5
                                }
                                else
                                {
                                    $global:hpos += $ctrl.PreferredSize.Width + 5
                                }
                                $global:vpos = $ctrl.top
                                $col += $(Get-CopyButton)
                            }
                        }

                        "DatePicker" {
                            $global:hpos += $ctrl.Width + 5
                            $tmpID = "$($global:hpos.ToString())$($global:vpos.ToString())"

                            $sctrl = Get-UIControl Image $null 0 "" @{Name="cal$tmpID";IconElements="cal.png";NoNewLine=1}
                            $sctrl.Add_Click({
                                # Show MonthCalendar
                                $id = "mcp$($this.Name.Substring(3))"
                                $mcp = $this.Parent.Controls.Find($id,$false)[0]
                                $mcp.Visible = !$mcp.Visible
                                $this.Parent.Controls.SetChildIndex($mcp, 0)
                            })
                            $col += $sctrl

                            $oldhpos = $global:hpos
                            $oldvpos = $global:vpos

                            if($OtherAttributes["DatePicker"] -eq "0")
                            {
                                $global:hpos -= 180
                                $global:vpos -= 159
                            }
                            else
                            {
                                $global:hpos -= $sctrl.Width
                                $global:vpos += $sctrl.Height
                            }

                            $sctrl = Get-UIControl MonthCalendar $null 0 "" @{Name="mcp$tmpID";Visible=0}
                            $sctrl.BackColor = "gainsboro"
                            $sctrl.Add_DateSelected({
                                $id = "cal$($this.Name.Substring(3))"
                                $imgCal = $this.Parent.Controls.Find($id,$false)[0]
                                $idx = $this.Parent.Controls.IndexOf($imgCal)
                                $tmp = [System.Windows.Forms.TextBox]$this.Parent.Controls[$($idx-1)]
                                $tmp.Text = $_.Start.ToShortDateString()
                                $this.Visible = $false
                            })
                            $col += $sctrl

                            $global:hpos = $oldhpos
                            $global:vpos = $oldvpos
                        }

                        "Help" {
                            $lastCtrl = $col | Select-Object -Last 1
                            $global:hpos = $lastCtrl.Left + $lastctrl.Width + 5   #it was using PreferredSize.Width
                            $sctrl = Get-UIControl "help" $OtherAttributes["Help"] 0 "" @{NoNewLine=1}
                            $col += $sctrl
                            $global:hpos = 22
                        }

                        "Multiline" {
                            $ctrl.AcceptsReturn = $true
                            $ctrl.Multiline = $true
                        }

                        "OpenPicker" {
                            $global:hpos += $ctrl.Width + 5
                            $sctrl = New-Object System.Windows.Forms.Button
                            $sctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
                            $sctrl.Size = New-Object System.Drawing.Size(20, 20)
                            $sctrl.Tag = $OtherAttributes["OpenPicker"]
                            $sctrl.Text = "..."
                            $sctrl.Add_Click({
                                $arr = $this.tag -split ","
                                $idx = $this.Parent.Controls.IndexOf($this)-1
                                $tmp = [System.Windows.Forms.TextBox]$this.Parent.Controls[$idx]
                                if($tmp.Text -ne "")
                                {
                                    $fdr = [System.IO.Path]::GetDirectoryName($tmp.Text)
                                    if($(Test-Path $fdr -PathType Container))
                                    {
                                        $arr[2] = $fdr
                                    }
                                }

                                $inFile = Get-UIFileOpenDialog $arr[2] $arr[1] $arr[0]   #InitialDir, $Filter, Title
                                if(-not [System.String]::IsNullOrEmpty($inFile))
                                {
                                    $tmp.Text = $inFile
                                }
                            })
                            $col += $sctrl
                        }

                        "Number" {
                            $ctrl.Add_KeyPress({
                                if (($_.KeyChar -eq 8) -or ($_.KeyChar -ge 48 -and $_.KeyChar -le 57)) {return}
                                if (($_.KeyChar -eq 46) -and $this.Text.IndexOf(".") -eq -1) {return}
                                $_.Handled = $true;
                            })
                        }

                        "Password" {
                            $ctrl.PasswordChar = "*"
                        }

                        "ReadOnly" {
                            $ctrl.ReadOnly = $OtherAttributes["ReadOnly"]
                            if($ctrl.ReadOnly)
                            {
                                $ctrl.Backcolor = "gainsboro"
                            }
                            else
                            {
                                $ctrl.Backcolor = ""
                            }
                        }

                        "SavePicker" {
                            $ctrl.Enabled = $false

                            $sctrl = New-Object System.Windows.Forms.Button
                            $sctrl.Location = New-Object System.Drawing.Point($($global:hpos+$size[0]), $global:vpos)
                            $sctrl.Size = New-Object System.Drawing.Size(20, 20)
                            $sctrl.Tag = $OtherAttributes["SavePicker"]
                            $sctrl.Text = "..."
                            $sctrl.Add_Click({
                                $arr = $this.tag -split ","
                                $inFile = Get-UIFileSaveDialog $arr[3] $arr[1] $arr[2] $arr[0]   #InitialDir, $InitialFileName $Filter, Title

                                if(-not [System.String]::IsNullOrEmpty($inFile))
                                {
                                    $idx = $this.Parent.Controls.IndexOf($this)-1
                                    $tmp = [System.Windows.Forms.TextBox]$this.Parent.Controls[$idx]
                                    $tmp.Text = $inFile
                                }
                            })
                            $col += $sctrl
                        }

                        "FolderPicker" {
                            $ctrl.Enabled = $false

                            $sctrl = New-Object System.Windows.Forms.Button
                            $sctrl.Location = New-Object System.Drawing.Point($($global:hpos+$size[0]), $global:vpos)
                            $sctrl.Size = New-Object System.Drawing.Size(20, 20)
                            $sctrl.Tag = $OtherAttributes["FolderPicker"]
                            $sctrl.Text = "..."
                            $sctrl.Add_Click({
                                $arr = $this.tag -split ","
                                $inFolder = Get-UIFolderSaveDialog "$($arr[0])" "$($arr[1])" "$($arr[2])" #InitialDir, $InitialFileName, DisableCreateNew

                                if(-not [System.String]::IsNullOrEmpty($inFolder))
                                {
                                    $idx = $this.Parent.Controls.IndexOf($this)-1
                                    $tmp = [System.Windows.Forms.TextBox]$this.Parent.Controls[$idx]
                                    $tmp.Text = $inFolder
                                }
                            })
                            $col += $sctrl
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }

                        "NoNewLine" {
                            $NoNewLine = $OtherAttributes["NoNewLine"]
                            $lastCtrl = $col | Select-Object -Last 1
                            $global:hpos += $lastctrl.Width + 5
                        }
                    }
                }

                if($OtherAttributes["Required"] -ne $null -or $OtherAttributes["ValidateString"] -ne $null -or `
                  ($OtherAttributes["Number"] -ne $null -and ($OtherAttributes["Max"] -ne $null -or $OtherAttributes["Min"] -ne $null)))
                {
                    if($OtherAttributes["Number"] -ne $null)
                    {
                        if($OtherAttributes["Max"] -ne $null)
                        {
                            $ctrl.tag += "Max={0};" -f $OtherAttributes["Max"]
                        }
                        if($OtherAttributes["Min"] -ne $null)
                        {
                            $ctrl.tag += "Min={0};" -f $OtherAttributes["Min"]
                        }
                    }

                    if($OtherAttributes["Required"] -ne $null)
                    {
                        $ctrl.tag += "Required=1;"
                    }

                    if($OtherAttributes["ValidateString"] -ne $null)
                    {
                        $ctrl.tag += "ValidateString={0};" -f $OtherAttributes["ValidateString"]
                    }

                    $ctrl.Add_Validating({
                        $strReq = Get-Instr $this.tag "Required=" ";"
                        if(![System.String]::IsNullOrEmpty($strReq) -and [System.String]::IsNullOrEmpty($this.Text))
                        {
                            $this.FindForm().Tag.SetError($this, "Required field");
                            $_.Cancel = $true
                        }
                        else
                        {
                            $strValid = Get-Instr $this.tag "ValidateString=" ";"
                            if(![System.String]::IsNullOrEmpty($strValid) -and $this.Text -ne $strValid)
                            {
                                $this.FindForm().Tag.SetError($this, "Type exact string '$strValid' in order to continue")
                                $_.Cancel = $true
                            }
                            else
                            {
                                $tmp = Get-Instr $this.tag "Max=" ";"
                                if(![System.String]::IsNullOrEmpty($tmp))
                                {
                                    $intMax = [decimal]$tmp
                                    if([decimal]$this.Text -gt $intMax)
                                    {
                                        $this.FindForm().Tag.SetError($this, "It can't be greater than $intMax")
                                        $_.Cancel = $true
                                    }
                                }

                                $tmp = Get-Instr $this.tag "Min=" ";"
                                if(![System.String]::IsNullOrEmpty($tmp))
                                {
                                    $intMin = [decimal]$tmp
                                    if([decimal]$this.Text -lt $intMin)
                                    {
                                        $this.FindForm().Tag.SetError($this, "It can't be less than $intMin")
                                        $_.Cancel = $true
                                    }
                                }
                            }
                        }
                        if(!$_.Cancel)
                        {
                            $this.FindForm().Tag.SetError($this, "")
                        }
                    })
                }

                $ctrl = $col
            }

            if(!$NoNewLine)
            {
                $tmp = $ctrl | Select-Object -first 1
                if(!$NoNewLine -and $tmp.Visible)
                {
                    $global:vpos += $tmp.Height + 15
                }
            }
        }

        "treeview" {
            $ctrl = New-Object System.Windows.Forms.TreeView
            $ctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
            if($mode -eq "view")
            {
                $ctrl.Enabled = $false
            }

            if($OtherAttributes -ne $null)
            {
                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }
            }

            if($value -ne $null)
            {
                if($value[0].GetType().Name -eq "hashtable")
                {
                    $tmp = ""
                    $value[0].Keys | ForEach-Object {
                        if($_ -ne $tmp)
                        {
                            $saNode = Add-Node $ctrl $_ "" "0"
                            $tmp = $_
                        }

                        if($value[0][$_] -ne $null)
                        {
                            Add-Node $saNode $value[0][$_] "" "1" | Out-Null
                        }
                    }
                }
                else
                {
                    $value | ForEach-Object {
                        Add-Node $ctrl $_ "" "0" | Out-Null
                    }
                }
            }
            $global:vpos += $size[1]
        }

        "updown" {
            $ctrl = New-Object System.Windows.Forms.DomainUpDown
            $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
            if($size -eq $null -or $size[0] -eq 0)	   # default 100 pixel if width is not provided
            {
                $ctrl.Width=100
            }
            else
            {
                if($size.Length -gt 1)
                {
                    $ctrl.Multiline = $true
                    $ctrl.Size = New-Object System.Drawing.Size($size[0], $size[1])
                }
                else
                {
                    $ctrl.Size = New-Object System.Drawing.Size($size[0], 30)
                }
            }
            $ctrl.ReadOnly = $true

            if($mode -eq "view")
            {
                $ctrl.Enabled = $false
            }

            if($OtherAttributes -ne $null)
            {
                $col = @()
                $col += $ctrl

                foreach($key in $OtherAttributes.Keys)
                {
                    switch($key)
                    {
                        "Elements" {
                            $colText = $OtherAttributes["Elements"] -split ","
                            $colText | ForEach-Object {
                                if($_.indexOf("-") -eq -1)
                                {
                                    $ctrl.Items.Add($_)
                                }
                                else
                                {
                                    $arr = $_.split("-")
                                    for($i=[int]$arr[0];$i -le [int]$arr[1];$i++)
                                    {
                                        $ctrl.Items.Add($i)
                                    }
                                }
                            }
                        }

                        "Help" {
                            if($ctrl.Visible)
                            {
                                if($ctrl.AutoSize)
                                {
                                    $global:hpos += $ctrl.PreferredSize.Width
                                }
                                else
                                {
                                    $global:hpos += $size[0] + 5
                                }
                                $sctrl = Get-UIControl "help" $OtherAttributes["Help"] 0 "" @{NoNewLine=1}
                                $col += $sctrl
                            }
                        }

                        "NoNewLine" {
                            $NoNewLine = $OtherAttributes["NoNewLine"]
                            $global:hpos += $ctrl.Width + 5
                        }

                        default {
                            try {
                                $ctrl.$($key) = $OtherAttributes[$key]
                            }
                            catch {

                            }
                        }
                    }
                }

                $ctrl = $col
            }

            if($value.count -gt 0)
            {
                if(-not [string]::IsNullOrEmpty($value[0]))
                {
                    $tmp = $ctrl | Select-Object -First 1
                    $tmp.SelectedIndex = $ctrl.Items.IndexOf("$($value[0])")
                }
            }

            if(!$NoNewLine)
            {
                $tmp = $ctrl | Select-Object -First 1
                if($tmp.Visible)
                {
                    $global:vpos += $allHeight + 35
                }
            }
        }

        "radiobutton" {
            if($OtherAttributes["Text"] -ne $null)
            {
                $col = @()

                $ctrl = New-Object System.Windows.Forms.Panel
                $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
                $ctrl.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
                $ctrl.AutoSize = $true

                if($OtherAttributes["Tooltip"] -ne $null)
                {
                    $arrRBTooltips = $OtherAttributes["Tooltip"] -split ","
                }

                $colText = $OtherAttributes["Text"] -split ","
                $i = 1
                $hpos = 0
                $vpos = 0
                ForEach($tmp in $colText)
                {
                    if($tmp -eq "")
                    {
                        $hpos += 20
                    }
                    else
                    {
                        $blnEventAdded = $false
                        if($tmp.indexOf("|") -ne -1)
                        {
                            $arr = $tmp.Split("|")
                            $itemval = $arr[0]
                            $itemtxt = $arr[1]
                        }
                        else
                        {
                            $itemval = $tmp
                            $itemtxt = $tmp
                        }

                        $sctrl = New-Object System.Windows.Forms.RadioButton
                        $sctrl.Location = New-Object System.Drawing.Point($hpos, $vpos)
                        $sctrl.AutoSize = $true
                        if($OtherAttributes["NormalAppearance"] -eq $null)
                        {
                            $sctrl.Appearance = [System.Windows.Forms.Appearance]::Button
                            $sctrl.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                        }
                        $sctrl.Text = $itemtxt
                        $sctrl.Name = $itemval	# tag is used for child toggling

                        if($value.Count -gt 0)
                        {
                            if($value[0].GetType().Name -eq "Boolean")
                            {
                                if($OtherAttributes["NormalAppearance"] -eq $null)
                                {
                                    if(($itemval -eq "On" -or $itemval -eq "Yes" -or $itemval -eq "true" -or $itemval -eq 1) -and $value[0])
                                    {
                                        $sctrl.checked = $true
                                        $ctrl.Tag= $itemval
                                    }
                                    elseif(($itemval -eq "Off" -or $itemval -eq "No" -or $itemval -eq "false" -or $itemval -eq 0) -and -not $value[0])
                                    {
                                        $sctrl.checked = $true
                                        $ctrl.Tag = $itemval
                                    }
                                }
                                if($OtherAttributes["Opposite"] -ne $null)
                                {
                                    $sctrl.Checked = !$sctrl.Checked
                                }
                            }
                            elseif($itemval -eq $value[0])
                            {
                                $sctrl.checked = $true
                                $ctrl.Tag= $itemval
                            }
                        }
                        elseif($_ -eq $colText[0])
                        {
                            #Preset the first selection to parent's tag if no value is provided
                            $ctrl.Tag = $colText[0]
                        }

                        if($mode -eq "view")
                        {
                            $sctrl.Enabled = $false
                        }

                        $vert = $false
                        if($OtherAttributes -ne $null)
                        {
                            if($OtherAttributes["Name"] -ne $null)
                            {
                                $ctrl.Name = $OtherAttributes["Name"]
                            }
                            if($OtherAttributes["Vertical"] -ne $null)
                            {
                                $vert = $true
                            }
                        }

                        if(-not $blnEventAdded)
                        {
                            $sctrl.Add_CheckedChanged({
                                if($this.checked)
                                {
                                    $this.parent.tag = $this.Name
                                }
                            })
                        }

                        if($arrRBTooltips -ne $null -and $arrRBTooltips[$i-1] -ne "")
                        {
                            Set-UIToolTip $sctrl $arrRBTooltips[$i-1]
                        }

                        $ctrl.Controls.Add($sctrl)
                        #$col+= $sctrl
                        if($vert)
                        {
                            $vpos += 20
                        }
                        else
                        {
                            $hpos += $sctrl.PreferredSize.Width
                        }
                        $i++
                    }
                }
                if($vpos -gt 0)
                {
                    $global:vpos += $vpos - 35
                }
                #$ctrl = $col
            }
            else	# single selection?  usually the Text is specified
            {
                $ctrl = New-Object System.Windows.Forms.RadioButton
                $ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
                $ctrl.AutoSize = $true
                $ctrl.Appearance = [System.Windows.Forms.Appearance]::Button
                $ctrl.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                if($value -ne $null)
                {
                    $ctrl.Text = $value[0]
                }
                if($mode -eq "view")
                {
                    $ctrl.Enabled = $false
                }
            }

            if($OtherAttributes["Help"] -ne $null)
            {
                $col = @()
                $col += $ctrl
                $lastCtrl = $ctrl | Select-Object -Last 1
                $global:hpos = $lastCtrl.Left + $lastctrl.PreferredSize.Width + 5
                    $ctrl = Get-UIControl "help" $OtherAttributes["Help"] 0 "" @{NoNewLine=1}
                $col += $ctrl
                $ctrl = $col
                $global:hpos = 22
            }
            elseif($OtherAttributes["NoNewLine"] -ne $null)
            {
                $NoNewLine = $OtherAttributes["NoNewLine"]
                $global:hpos += $ctrl.PreferredSize.Width + 5
            }

            if(!$NoNewLine)
            {
                 $global:vpos += 40
            }

            If($OtherAttributes -ne $null -and $OtherAttributes["ToggleChildDisplay"] -ne $null)
            {
                if($OtherAttributes["ToggleChildDisplay"].Count -gt 1)
                {
                    $arrTmp = $OtherAttributes["ToggleChildDisplay"]
                }
                else
                {
                    $tmp = $OtherAttributes["ToggleChildDisplay"].ToString()
                    if($tmp.indexOf(",") -eq -1)
                    {
                        $tmp = "800,$tmp"
                    }
                    $arrTmp = $tmp -split ","
                }
                [array]$arrSize = foreach($tmp in $arrTmp) {([int]::parse($tmp))}

                $col = @()
                $col += $ctrl
                $tmp = $ctrl | Select-Object -first 1
                $tmp.Controls | ForEach-Object {
                    $_.Add_CheckedChanged({
                        if($this.checked) {$this.parent.tag = $this.Name}

                        $iSelected = $this.Parent.Controls.IndexOf($this)
                        $idx = $this.Parent.Parent.Controls.IndexOf($this.Parent)

                        # if it has help control
                        if($this.Parent.Controls[$($idx+1)] -is [System.Windows.Forms.Label])
                        {
                            $idx += 1
                        }

                        $this.Parent.Parent.Controls[$($idx+$iSelected+1)].Visible = $this.Checked
                    })
                }

                $i=0
                $tmp.Controls | ForEach-Object {
                    $blnVisible = $_.Checked
                    $global:hpos = 0
                    $tmp = Get-UIControl panel "ChildPanel$i" $arrSize "" @{Visible=$blnVisible}
                    $col += $tmp
                    $i++
                }
                $ctrl = $col

                $global:vpos += [int]$arrSize[1]
            }
        }

        default {
            Write-Warning "$($myInvocation.MyCommand.Name): Unknown control type '$ControlType'"
        }
    }

    # reset hpos
    if($ControlType -ne "caption")
    {
        if(!$NoNewLine)
        {
              $global:hpos = 22
        }
    }

    return $ctrl
}

<#
    .SYNOPSIS
        Set control's tooltip

    .PARAMETER StrToolTip
        Tooltip text

    .PARAMETER Show
        Show tooltip right away

    .EXAMPLE
        example
#>
Function Set-UITooltip
{
    param(
        $Control,
        [string]$StrTooltip,
        [switch]$Show
    )

    $ToolTip = New-Object System.Windows.Forms.ToolTip
    $ToolTip.BackColor = [System.Drawing.Color]::LightGoldenrodYellow
    $ToolTip.IsBalloon = $true
    $ToolTip.InitialDelay = 500
    $ToolTip.ReshowDelay = 500
    $ToolTip.SetToolTip($Control, $StrTooltip)

    if($Show)
    {
        $ToolTip.Show($StrTooltip, $Control, 1500)
    }
}
