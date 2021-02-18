_Screen.Icon = "Fox-64.ico"
_Screen.Caption = "DPI Testing"

* CTRL+D on a form displays its dimensions
ON KEY LABEL CTRL+D Dimensions()

* put the class in scope
DO DPIAwareManager.prg

LOCAL DPI AS DPIAwareManager

m.DPI = CREATEOBJECT("DPIAwareManager")
* the VFP screen will be managed
m.DPI.Manage(_Screen)
* and we'll want to see a log
m.DPI.Log()

* create a screen extension manager to demonstrate a DPI-aware menu
_Screen.AddObject("DPIAwareScreenManager", "ScreenManager")

* a new menu pad to extend the system menu
DEFINE PAD padDPIAware OF _MSYSMENU PROMPT "DPIAware"
DEFINE POPUP popDPIAware MARGIN RELATIVE
ON PAD padDPIAware OF _MSYSMENU ACTIVATE POPUP popDPIAware
DEFINE BAR 1 OF popDPIAware PROMPT "DPI-aware menu bars" FONT "Arial", 8
DEFINE BAR 2 OF popDPIAware PROMPT "Current scale: 100%" FONT "Arial", 8

ACTIVATE SCREEN

* attention! the browse window is not manageable
BROWSE NOWAIT LAST

LOCAL ARRAY ManagedForms[1], UnmanagedForms[1]

* a basic form with info - shown in screen
DO FORM "monitor dpi in screen.scx" NAME m.ManagedForms[1] LINKED NOSHOW

* manage and display it
m.DPI.Manage(m.ManagedForms[1])
m.ManagedForms[1].Show()

LOCAL ARRAY SCX[1]
LOCAL NumSCX AS Integer
LOCAL Term AS Terminator

m.Term = CREATEOBJECT("Terminator")

* go through all the test forms in the forms folder

FOR m.NumSCX = 1 TO ADIR(m.SCX, "forms\*.scx")

	DIMENSION m.ManagedForms[m.NumSCX + 1]

	* instantiate the form
	DO FORM ("forms\" + m.SCX[m.NumSCX, 1]) NAME m.ManagedForms[m.NumSCX + 1] LINKED NOSHOW

	* terminate the test application whem a form is closed
	BINDEVENT(m.ManagedForms[m.NumSCX + 1], "Destroy", m.Term, "Done")

	* manage and show the form
	m.DPI.Manage(m.ManagedForms[m.NumSCX + 1])
	m.ManagedForms[m.NumSCX + 1].Show()

ENDFOR

* go through all the unmanaged test forms in the unmanagedforms folder

FOR m.NumSCX = 1 TO ADIR(m.SCX, "unmanagedforms\*.scx")

	DIMENSION m.UnmanagedForms[m.NumSCX]

	* instantiate the form
	DO FORM ("unmanagedforms\" + m.SCX[m.NumSCX, 1]) NAME m.UnmanagedForms[m.NumSCX] LINKED NOSHOW

	* terminate the test application whem a form is closed
	BINDEVENT(m.UnmanagedForms[m.NumSCX], "Destroy", m.Term, "Done")

	* show the form, but don't manage it
	m.UnmanagedForms[m.NumSCX].Show()

ENDFOR

* remember how to quit
MESSAGEBOX("Close a form to quit!")

READ EVENTS


PROCEDURE Dimensions ()

	LOCAL ARRAY ObjInto(1)
	LOCAL DF AS Form

	IF AMOUSEOBJ(m.ObjInto, 1) != 0
		m.DF = m.ObjInto(2)
		MESSAGEBOX(TEXTMERGE("<<m.DF.Name>>: Width = <<m.DF.Width>>, Height = <<m.DF.Height>>"))
	ENDIF

ENDPROC

DEFINE CLASS Terminator AS Custom

	FUNCTION Done
		CLEAR EVENTS
	ENDFUNC

ENDDEFINE

DEFINE CLASS ScreenManager AS DPIAwareScreenManager OF ../source/dpiawaremanager.prg

	FUNCTION SelfManage (DPIScale AS Integer, DPINewScale AS Integer)

		LOCAL NewFontSize AS Integer

		RELEASE BAR ALL OF popDPIAware
		
		m.NewFontSize = ROUND(8 * m.DPINewScale / 100, 0)

		DEFINE BAR 1 OF popDPIAware PROMPT "DPI-aware menu bars" FONT "Arial", m.NewFontSize
		DEFINE BAR 2 OF popDPIAware PROMPT TEXTMERGE("Current scale: <<m.DPINewScale>>%") FONT "Arial", m.NewFontSize

	ENDFUNC


ENDDEFINE


