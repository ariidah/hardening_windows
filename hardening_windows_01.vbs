' @ariidah hardening via vbscript
' 200526 - change matching extention to regex mode, change "DEBUG" boolean to "console_mode" -
' automatically fill and verbose output when running via cscript.exe
' 200418 - whitelist mode for GNUPG binary (gpg.exe)
' 200126 - initial
dim drive,sdrive
dim xa,xb
dim console_mode,blacklist,whitelist
blacklist=false
repeat=true

set ext_regex = new RegExp
with ext_regex
	.pattern = _
	"(rar)|(exe)|(vbe)|(vbs)$"
	.ignorecase = true
	.global = false
end with

set proc_regex = new RegExp
with proc_regex
	.pattern = _
	"(gpg)" & _
	".exe$"
	.ignorecase = false
	.global = false
end with

set fs = createObject("scripting.filesystemobject")
set sh = createObject("wscript.shell")
set sa = createObject("shell.application")

do while true
	on error resume next
	set wm = getObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	if wm <> nothing then exit do
	wscript.sleep 1000
loop

set ext_regex = new RegExp
with ext_regex
	.pattern = _
	".(rar)|(exe)|(vbe)$"
	.ignorecase = true
	.global = false
end with

set proc_regex = new RegExp
with proc_regex
	.pattern = _
	"(gpg)" & _
	".exe$"
	.ignorecase = false
	.global = false
end with

if fs.getFile(wscript.fullname).name  = "cscript.exe" then
	console_mode=true
	wscript.echo _
	"@ariidah 2020 MEI 26" & vbcrlf & _
	"Eksekusi butuh Administrator Privileges dengan host wscript.exe" & vbcrlf & vbcrlf & _
	"MODE DEBUG hanya akan mengeksekusi sub allowrd()" & vbcrlf & _
	"[menonaktifkan blocking removable flashdrive]" & vbcrlf
else
	console_mode=false
end if

sub killprocess(byval ptarget)
	set w32_proc = wm.execquery("SELECT * FROM WIN32_PROCESS WHERE NAME LIKE '%" & ptarget & "%'")
	for each proc in w32_proc
		on error resume next
		set w32_ppid = wm.execquery("SELECT * FROM WIN32_PROCESS WHERE PROCESSID LIKE '" & proc.parentProcessID & "'")
		for each ppid in w32_ppid
			on error resume next
			if proc_regex.test(ppid.name) then
				whitelist = true
			else
				whitelist = false
			end if
			pname = ppid.name
		next
		if not whitelist then
			if  not console_mode then
				proc.Terminate()
			else
				wscript.echo pname & "/" & proc.parentProcessId & vbTab & proc.name & "/" & proc.processid 
			end if
		end if
	next
	set w32_proc = nothing
end sub

sub allowrd()
	key="HKLM\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}"
	sh.regwrite key&"\Deny_Write",0,"REG_DWORD"
	sh.regwrite key&"\Deny_Read",0,"REG_DWORD"
end sub
allowrd

sub denyrd()
	key="HKLM\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}"
	sh.regwrite key&"\Deny_Write",1,"REG_DWORD"
	sh.regwrite key&"\Deny_Read",1,"REG_DWORD"
end sub

sub find_recurse(byval folder)
	if not fs.folderExists(folder) then
		exit sub
	end if
	set localdir=fs.getFolder(folder)
	for each file in localdir.files
		on error resume next
		if ext_regex.test(file.name) then
			if not blacklist then blacklist = true
			if console_mode then
				wscript.echo file.path
			else
				'baris dibawah ini akan menghapus file di removable media yang MATCH dengan ext_regex
				'fs.deletefile file.path
			end if
		end if
	next
	for each folder in localdir.subfolders
		on error resume next
		find_recurse folder.path
	next
end sub

while true
	killprocess "conhost.exe"
	for each drive in fs.drives
		xa=xa+1
		if(drive.drivetype = 1 and ( xb < xa or repeat ) and drive.isready) then
			find_recurse drive.path
			if blacklist and not console_mode then
				while (drive.isready)
					on error resume next
					sa.namespace(17).parsename(drive).invokeverb("eject")
					wscript.sleep 1000
				wend
				denyrd
			end if
		end if
	next
	xb=fs.drives.count
	xa=0
	wscript.sleep 1000
wend
