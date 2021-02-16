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

ACTIVATE SCREEN

* attention! the browse window is not manageable
BROWSE NOWAIT LAST

LOCAL ARRAY ManagedForms[1]

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
