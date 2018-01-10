# region: non-UI Helpers 
$comparerClassString = @"
using System.Collections;	
using System.Windows.Forms;

public class ListViewColumnSorter : IComparer
{
	private int ColumnToSort;
	private SortOrder OrderOfSort;
	private CaseInsensitiveComparer ObjectCompare;

	public ListViewColumnSorter()
	{
		// Initialize the column to '0'
		ColumnToSort = 0;

		// Initialize the sort order to 'none'
		OrderOfSort = SortOrder.None;

		// Initialize the CaseInsensitiveComparer object
		ObjectCompare = new CaseInsensitiveComparer();
	}

	public int Compare(object x, object y)
	{
		int compareResult = 0;
		ListViewItem listviewX, listviewY;

		listviewX = (ListViewItem)x;
		listviewY = (ListViewItem)y;

        if (listviewX.ListView.Columns[ColumnToSort].TextAlign != System.Windows.Forms.HorizontalAlignment.Right)
        {
            try
            {
                var dX = System.DateTime.Parse(listviewX.SubItems[ColumnToSort].Text);
                var dY = System.DateTime.Parse(listviewY.SubItems[ColumnToSort].Text);
                compareResult = ObjectCompare.Compare(dX, dY);
            }
            catch {
            	compareResult = ObjectCompare.Compare(listviewX.SubItems[ColumnToSort].Text,listviewY.SubItems[ColumnToSort].Text);
            } 
        }
        else
        {
            decimal fX = 0;
            decimal fY = 0; 
            try
            {
                fX = decimal.Parse(System.Text.RegularExpressions.Regex.Replace(listviewX.SubItems[ColumnToSort].Text, @"[A-Za-z\s]", string.Empty));
                fY = decimal.Parse(System.Text.RegularExpressions.Regex.Replace(listviewY.SubItems[ColumnToSort].Text, @"[A-Za-z\s]", string.Empty));
                //decimal fX = decimal.Parse(listviewX.SubItems[ColumnToSort].Text);
                //decimal fY = decimal.Parse(listviewY.SubItems[ColumnToSort].Text);
            }
            catch {} 
            compareResult = ObjectCompare.Compare(fX,fY);        
        }
			
		if (OrderOfSort == SortOrder.Ascending)
		{
			return compareResult;
		}
		else if (OrderOfSort == SortOrder.Descending)
		{
			return (-compareResult);
		}
		else
		{
			return 0;
		}
	}
    
	public int SortColumn
	{
		set
		{
			ColumnToSort = value;
		}
		get
		{
			return ColumnToSort;
		}
	}

	public SortOrder Order
	{
		set
		{
			OrderOfSort = value;
		}
		get
		{
			return OrderOfSort;
		}
	}
    
}
"@
if(-not ([System.Management.Automation.PSTypeName] "ListViewColumnSorter").Type)
{
    Add-Type -TypeDefinition $comparerClassString -ReferencedAssemblies ('System.Windows.Forms', 'System.Drawing')
}

function Add-NativeHelperType
{
    $nativeHelperTypeDefinition =
    @"
    using System;
    using System.Runtime.InteropServices;

    public static class NativeHelper
        {
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool SetForegroundWindow(IntPtr hWnd);

        public static bool SetForeground(IntPtr windowHandle)
        {
           return NativeHelper.SetForegroundWindow(windowHandle);
        }
    }
"@
if(-not ([System.Management.Automation.PSTypeName] "NativeHelper").Type)
    {
        Add-Type -TypeDefinition $nativeHelperTypeDefinition
    }
}

Add-Type @"
public class ListItem
{
    private string _text;
    private string _value;
    private string _tag;

    public string Text
    {
        get { return _text; }
        set { _text = value; }
    }

    public string Value
    {
        get { return _value; }
        set { _value = value; }
    }

    public string Tag
    {
        get { return _tag; }
        set { _tag = value; }
    }

    public ListItem()
    {
    }

    public ListItem(string text, string value)
    {
        _text = text;
        _value = value;
    }
}
"@

<#
    .SYNOPSIS
        Determine if the current environment is running in PowerISE

    .PARAMETER param1
        param1

    .EXAMPLE
        example
#>
function IsISE()
{
    return ([environment]::commandline -like "*powershell_ise.exe*")
}

<#
    .SYNOPSIS
        Extract substring 

    .PARAMETER strSource
        Specifies the source string 

    .PARAMETER strStart
        Specifies the string to search where the substring is started with

    .PARAMETER strEnd
        Specifies the source string where the substring is ended with 

    .EXAMPLE
        example
#>
Function Get-Instr
{
	param(
		[Parameter(Mandatory=$true)][string]$strSource,
		[string]$strStart, 
		[string]$strEnd
	)
	
    if($strStart -eq "")
    {
        $start = 0
    }
    elseif($strStart.StartsWith("-"))
    {
        $strStart = $strStart.Substring(1)
        $start = $strSource.LastIndexOf($strStart ,[System.StringComparison]::CurrentCultureIgnoreCase)
    }
    else
    {
	    $start = $strSource.indexOf($strStart ,[System.StringComparison]::CurrentCultureIgnoreCase)
    }
	if($start -ge 0)
	{
		if($strEnd -eq "")
		{
			Return $strSource.substring($start+$strStart.Length)
		}
		else
		{
			if($strEnd -eq "")
			{
				return $strSource.substring($start+$strStart.Length)
			}
			else
			{
                if($strEnd.StartsWith("-"))
                {
                    $strEnd = $strEnd.SubString(1)
				    $end = $strSource.LastIndexOf($strEnd, [System.StringComparison]::CurrentCultureIgnoreCase)                                        
                }
                else
                {
				    $end = $strSource.indexOf($strEnd, $start+$strStart.Length, [System.StringComparison]::CurrentCultureIgnoreCase)
                }

				if($end -ne -1)
				{
					return $strSource.substring($start+$strStart.Length, $end - $start - $strStart.Length)
				}
			}
		}
	}
}

<#
    .SYNOPSIS
        Provided an clipboard icon and associated function to copy text to clipboard 

    .PARAMETER param1
        param1

    .EXAMPLE
        example
#>
Function Get-CopyButton
{
    $ctrl = New-Object System.Windows.Forms.Label
	$ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
	$ctrl.AutoSize = $true
    $ctrl.Font = new-object System.Drawing.font("WingDings 2", 12, [System.Drawing.FontStyle]::Regular)
    $ctrl.ForeColor = "green"
    $ctrl.Text = "2"

	$ctrl.Add_Click({
        $idx = $this.Parent.Controls.IndexOf($this)-1
        $tmp = $this.Parent.Controls[$idx]
        if($tmp -is [System.Windows.Forms.LinkLabel])
        {
            $txtCopy = $tmp.Links[0].LinkData
            [Windows.Forms.Clipboard]::SetText($txtCopy)
        }
        else
        {
            $txtCopy = $tmp.Text
        }

        if([System.String]::IsNullOrEmpty($txtCopy))
        {
            Get-UIMessageBox "Information is not copied"
        }
        else
        {
            [Windows.Forms.Clipboard]::SetText($txtCopy)
            Get-UIMessageBox "Information is copied to the clipboard"
        }
    })
    #$global:hpos += 10
    return $ctrl 
}

Function Get-ADPickerButton
{
    param([bool]$blnMultiple, [string]$strFields, [bool]$Group)

    $ctrl = New-Object System.Windows.Forms.Label
    $ctrl.Name = "lblADPicker"
	$ctrl.Location = New-Object System.Drawing.Point($global:hpos, $global:vpos)
	$ctrl.AutoSize = $true
    $ctrl.Font = new-object System.Drawing.font("WebDings", 12, [System.Drawing.FontStyle]::Regular)
    $ctrl.ForeColor = "green"
    $ctrl.Text = "m"

    if($blnMultiple)
    {
        $ctrl.tag = "*"
    }
    else
    {
        $ctrl.Tag = ""
    }
    if($Group)
    {
        $ctrl.tag += "%"
    }
    $ctrl.Tag += $strFields

	$ctrl.Add_Click({
        $idx = $this.Parent.Controls.IndexOf($this)-1
        $tmp = $this.Parent.Controls[$idx]
        $rtn = Open-PeoplePickerWindow $this.tag
        if($rtn -ne $null)
        {
            $rtn | ForEach-Object {
                if($tmp.FindStringExact($_.Text) -eq -1)
                {
                    $tmp.Items.Add($_)
                }
            }
        }
    })
    return $ctrl 
}

Function Open-PeoplePickerWindow
{
    param([string]$strTag)

    if($strTag.StartsWith("%") -or $strTag.StartsWith("*%"))
    {
        $form2 = Get-UIWinForm "Group Picker" "" "^Select","Cancel" 400 300        
    }
    else
    {
        $form2 = Get-UIWinForm "People Picker" "" "^Select","Cancel" 400 300
    }

    $ctrl = Get-UIControl "Caption" "Search :" 50 
    $form2.Controls.Add($ctrl)

    $ctrl = Get-UIControl "textbox" "" 250 "edit" @{Name="txtSearch";NoNewLine=1}
    $form2.Controls.Add($ctrl)

	$ctrl = Get-UIControl Button "Search" "" "" @{Name="btnSearch"}
	$form2.Controls.Add($ctrl)
    $form2.AcceptButton = $ctrl

    if($strTag.StartsWith("*"))
    {
        $ctrl.Tag = $strTag.Substring(1)
        $CtrlType = "CheckListBox" 
    }
    else
    {
        $ctrl.Tag = $strTag
        $CtrlType = "ListBox"
    }
    $ctrl = Get-UIControl $CtrlType "" 300,220 "edit" @{Name="clbPeople"}

	$ctrl.DisplayMember = "text"
	$ctrl.ValueMember = "value"    
    $form2.Controls.Add($ctrl)

	$btnSearch = $form2.Controls.Find("btnSearch",$true)[0]
    if($btnSearch -ne $null)
    {
        $btnSearch.Add_Click({
            $tmp = $this.tag 
            $btnSelect = $form2.Controls.Find("btnSelect",$true)[0]  
            $txtName= $form2.Controls.Find("txtSearch",$true)[0] 
            $Account = $txtName.Text.Trim()    
            if($Account -eq "" -or  $Account.Trim() -eq "*") { return }
            $pos = $Account.LastIndexOf("{0}\" -f [Environment]::userdomainname,  [System.StringComparison]::CurrentCultureIgnoreCase)
            if($pos -ge 0)
            {
                $Account = $Account.substring($pos+[Environment]::userdomainname.Length+1)
            }

            if($tmp.StartsWith("%"))
            {
                $strFilter = "(&(ObjectCategory=group)(name=$Account*))"
            }
            else
            {
                if($Account.indexof("@") -ne -1)
                {
                    $strFilter = "(&(ObjectCategory=user)(mail={0}))" -f $Account
                }
                elseif($(isNumeric($Account)))
                {
                    $strFilter = "(&(ObjectCategory=user)(userprincipalname=$Account@mil))"
                }
                elseif($Account.indexof(",") -ne -1)
                {
                    $arr = $Account.split(",")
                    $strFilter = "(&(ObjectCategory=user)(givenName={0})(sn={1}))" -f $arr[1].Trim(),$arr[0].Trim()
                }
                elseif($Account.indexof(" ") -ne -1)
                {
                    $arr = $Account.split(" ")
                    $strFilter = "(&(ObjectCategory=user)(givenName={0})(sn={1}))" -f $arr[0].Trim(),$arr[1].Trim()
                }
                else
                {
                    $strFilter = "(&(ObjectCategory=user)(givenName={0}))" -f $Account
                }
                $strFilter = $strFilter.Replace("(givenName=)","").Replace("(sn=)","")
            }

            $this.FindForm().Cursor = [System.Windows.Forms.Cursors]::WaitCursor
            $results = (New-Object DirectoryServices.DirectorySearcher $strFilter).FindAll()
            $this.FindForm().Cursor = [System.Windows.Forms.Cursors]::Default

            $ctrl.Items.Clear()

            if($results.count -eq 0)
            {
                $btnSelect.Enabled = $false 
                msgbox "No information found based on the criteria"
            }
            else
            {
                if($tmp.StartsWith("%")) # Group
                {
                    if($tmp -eq "%")
                    {
                        $arr = "Name".split("+")
                    }
                    else
                    {
                        $arr = $tmp.substring(1).Split("+")
                    }
                }
                else
                {
                    if([System.String]::IsNullOrEmpty($tmp))
                    {
                        $arr = "DisplayName".split("+")
                    }
                    else
                    {
                        $arr = $tmp.Split("+")
                    }
                }
                $results | ForEach-Object {
                    $user = $_
                    $strDisplay = ""
                    $arr | ForEach-Object {
                        $strDisplay += $user.Properties[$_]
                        if($_ -ne $arr[-1])
                        {
                            $strDisplay += " - " 
                        }
                    }
                    $tmp = New-Object ListItem($strDisplay, $user.Properties["samaccountname"])
                    $tmp.Tag = $user.Properties["mail"]
                    if($user.count -eq 1)
                    {
                        if($ctrl -is [System.Windows.Forms.CheckedListBox])
                        {
                	        $ctrl.Items.Add($tmp, $true) | Out-Null
                        }
                        else
                        {
                	        $ctrl.Items.Add($tmp) | Out-Null                    
                            $ctrl.SelectedIndex = 0
                        }
                    }
                    else
                    {
                	    $ctrl.Items.Add($tmp) | Out-Null                    
                    }
                }
                $btnSelect.Enabled = $true
                $btnSelect.Focus()                 
            }
        })
    }

    $btnSelect = $form2.Controls.Find("btnSelect",$true)[0]  
    if($btnSelect -ne $null)
    {
        $btnSelect.Add_Click({
            $this.FindForm().DialogResult = [System.Windows.Forms.dialogResult]::OK
            if($ctrl -is [System.Windows.Forms.CheckedListBox])
            {
                $this.FindForm().Tag = $ctrl.CheckedItems
            }
            else
            {
                $this.FindForm().Tag = $ctrl.SelectedItem
            }
            $this.FindForm().Close()
        })
    }

    $form2.ShowDialog() | Out-Null
    if($form2.DialogResult -eq [System.Windows.Forms.dialogResult]::OK)
    {
        return $form2.tag 
    }
}

function isURIWeb($address) {  
    $uri = $address -as [System.URI]  
    $uri.AbsoluteURI -ne $null -and $uri.Scheme -match '[http|https]'  
}

function OpenHelpPopup
{
    param(
        [string]$fileName,
        [string]$FileNotFound,  #
        [switch]$NoEdit
    )
    
    if($NoEdit)
    {
        $form2 = Get-UIWinForm "Help" "" "Close" 600 480
    }
    else
    {
        $form2 = Get-UIWinForm "Help" "" "<Edit","Close" 600 480
        $btnEdit = $form2.Controls.Find("btnEdit",$true)[0]
        if($btnEdit -ne $null)
        {
            #open file
            $btnEdit.tag = $fileName
			$btnEdit.add_Click({
                # view file
                & cmd /c ("""{0}""" -f $this.tag)
			})
        }
    }
    #$form2.FormBorderStyle = "None"

    $global:hpos = 0;$global:vpos = 0
    $ctrl = Get-UIControl "richtextbox" "" 600,437 "view" @{File="$fileName";FileNotFound=$FileNotFound}
    $form2.Controls.Add($ctrl)
    $form2.VerticalSCroll.Value = 0

    $form2.ShowDialog() | Out-Null
}

<#
    .SYNOPSIS
        Determines if the provided value is numeric

    .PARAMETER Value 
        The value to be validated 

    .EXAMPLE
        example
#>
Function isNumeric 
{
	param($value)
	
	$IsNumeric = $false
    if($value -ne $null)
    {
    	try
    	{
    		0 + $value | Out-Null
    		$IsNumeric = $true
    	}
    	catch
    	{
    		$IsNumeric = $false
    	}
    }
	return $IsNumeric
}

Function Format-SizeWithUnit
{
    param([decimal]$value,
          [string]$strFormat)
 
    if($value -ge 1GB) {$size="GB"; $value = ($value/ 1GB)}
    ElseIf ($value -ge 1MB) {$size="MB"; $value = ($value/1MB)}
    ElseIf ($value -ge 1KB) {$size="KB"; $value = ($value/1KB)}
    Else {$size="Bytes"}
    $strFormat = $strFormat.Replace("[SIZE]",$size)
    
    return $([string]::Format($strFormat, $value))
}

Function Format-AgeWithUnit
{
    param([datetime]$value,
          [string]$strFormat)
 
    $tmp = $(Get-Date) - $value
    if($tmp.TotalSeconds -lt 2) {$age = "a second ago"}
    elseif($tmp.TotalMinutes -lt 1) {$age = "{0} seconds ago" -f $tmp.TotalSeconds}
    elseif($tmp.TotalMinutes -lt 2) {$age = "a minute ago"}
    elseif($tmp.TotalHours -lt 1) {$age = "{0} minutes ago" -f [int]$tmp.TotalMinutes}
    elseif($tmp.TotalHours -lt 2) {$age = "an hour ago"}
    elseif($tmp.TotalDays -lt 1) {$age = "{0} hours ago" -f [int]$tmp.TotalHours}
    elseif($tmp.TotalDays -lt 2) {$age = "yesterday"}
    elseif($tmp.TotalDays -lt 30) {$age = "{0} days ago" -f [int]$tmp.TotalDays}
    elseif($tmp.TotalDays -lt 60) {$age = "last month"}
    elseif($tmp.TotalDays -lt 365) {$age = "{0} months ago" -f [int]($tmp.TotalDays / 30)}
    elseif($tmp.TotalDays -lt 730) {$age = "last year"}
    else {$age = "{0} years ago" -f [int]($tmp.TotalDays / 365)}
    
    $strFormat = $strFormat.Replace("[AGE]",$age)
    
    return $([string]::Format($strFormat, $value))
}

Function GroupListView
{
    param(
        [System.Windows.Forms.ListView]$lv,
        [string]$GrpFld)

    $col = $lv.Columns | Where-Object {$_.Text -eq $GrpFld } | Select-Object -first 1 
    if($col -eq $null) {return}
     
    $lv.Items | ForEach-Object {
        $flag = $true 
        $strGroupName = $_.subItems[$($col.Index)].Text
        $lvg = $lv.Groups | Where-Object {$_.Name -eq $strGroupName}
        if($lvg -ne $null)
        {
            $_.Group = $lvg
            $flag = $false
        }
        
        if($flag)
        {
            $lstGrp = new-object System.Windows.Forms.ListViewGroup -ArgumentList $strGroupName, $strGroupName
            $lv.Groups.Add($lstGrp) | Out-Null
            $_.Group = $lstGrp
        }
        $flag = $true
    }
    $lv.columns[$($col.Index)].Width = 0  
    return $true 
}

Function GetListViewSubItemIndex
{
    Param
    (
        [System.Windows.Forms.ListView] $lv,
        [string] $colName
    )
    $intReturn = -1 
    $col = $lv.Columns | Where-Object {$_.Text -eq $colName } | Select-Object -first 1 
    if($col -ne $null)
    {
        $intReturn = $col.Index
    }
    return $intReturn 
}

Function SetDropdownSelectedItem
{
    param(
        $Control,
        $Value
    )

    if($value -is [System.Array])
    {
        $value = $value -join ""
    }
    elseif($value -isnot [System.String])
    {
        $value = $value.ToString()
    }

    $index = $Control.FindStringExact($value)
    if($index -ne [System.Windows.Forms.ListBox]::NoMatches)
    {
        $typeName = $Control.GetType().Name
        switch($typeName)
        {
            "combobox" {
                $ctrl.SelectedIndex = $index 
            }
            "listbox" {
                $ctrl.SetSelected($index, $true)                
            }
            "checkedlistbox" {
                $ctrl.SetItemChecked($index, $true)                                
            }
        }
    }
}

function Get-ImagefromFile
{
    param(
        $FileName
    )

    if(Test-Path $FileName)
    {
        $tmp = [System.IO.File]::ReadAllBytes($FileName)
        $tmp2 = New-Object -TypeName System.IO.MemoryStream -ArgumentList $tmp, $false
        $img = [Drawing.Image]::FromStream($tmp2)
        
        return $img
    }
}

function Open-IETabs 
{
    Param
    (
        [Parameter(Mandatory=$true)][string] $Url,
        [switch]$InForeground=$true
    )
    
    if($InForeground)
    {
        Add-NativeHelperType
    }

    $internetExplorer = new-object -com "InternetExplorer.Application"
    $internetExplorer.navigate($Url)
    $internetExplorer.Visible = $true
    if($InForeground -and $internetExplorer.HWND -ne $null)
    {
        [NativeHelper]::SetForeground($internetExplorer.HWND)
    }
    return $internetExplorer
}
