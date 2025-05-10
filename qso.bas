' M0MNF PicoCalc Field Logger
' FINAL VERSION - Manual Date/Time | Clean | Save | Edit | View
' PicoMite 5.09RC5 + PicoCalc

' --- Variables ---
DIM INTEGER selected
DIM INTEGER qso_count
DIM STRING callsign$, rst$, notes$
DIM STRING log$(500)
DIM STRING k$
DIM INTEGER keycode
DIM STRING session_date$, session_time$

' --- Functions ---
FUNCTION Clean$(s$)
  LOCAL INTEGER i
  LOCAL STRING r$
  r$ = ""

  FOR i = 1 TO LEN(s$)
    IF ASC(MID$(s$, i, 1)) >= 32 AND ASC(MID$(s$, i, 1)) <= 126 THEN
      r$ = r$ + MID$(s$, i, 1)
    ENDIF
  NEXT i

  Clean$ = r$
END FUNCTION

' --- Startup ---
CLS

' Ask for today's date and time
DO : k$ = INKEY$ : LOOP UNTIL k$ = ""
PRINT "Enter today's DATE (DD-MM-YYYY):"
INPUT session_date$
session_date$ = Clean$(session_date$)

DO : k$ = INKEY$ : LOOP UNTIL k$ = ""
PRINT
PRINT "Enter the current TIME (HH:MM):"
INPUT session_time$
session_time$ = Clean$(session_time$)

' --- Load existing logbook.txt (if exists) ---
qso_count = 0

ON ERROR SKIP
OPEN "logbook.txt" FOR INPUT AS #1
ON ERROR ABORT

IF MM.ERRNO = 0 THEN
  DO WHILE NOT EOF(#1)
    qso_count = qso_count + 1
    LINE INPUT #1, log$(qso_count)
  LOOP
  CLOSE #1
ENDIF

' --- Subroutines ---

SUB DrawMenu
  CLS
  PRINT
  PRINT "    M0MNF Field Contact Logger"
  PRINT "    =========================="
  PRINT
  PRINT "         Logged QSOs: "; qso_count
  PRINT

  IF selected = 1 THEN
    PRINT " > 1) Log a New Contact"
  ELSE
    PRINT "   1) Log a New Contact"
  ENDIF

  IF selected = 2 THEN
    PRINT " > 2) Show Logbook"
  ELSE
    PRINT "   2) Show Logbook"
  ENDIF

  IF selected = 3 THEN
    PRINT " > 3) Backup Instructions"
  ELSE
    PRINT "   3) Backup Instructions"
  ENDIF

  IF selected = 4 THEN
    PRINT " > 4) Edit Existing Contact"
  ELSE
    PRINT "   4) Edit Existing Contact"
  ENDIF

  IF selected = 5 THEN
    PRINT " > 5) Safe Shutdown"
  ELSE
    PRINT "   5) Safe Shutdown"
  ENDIF

  PRINT
  PRINT "  (Use 1-5 keys or UP/DOWN + ENTER)"
END SUB

SUB LogContact
  LOCAL INTEGER hndl

  CLS
  PRINT
  PRINT "Log a New Contact"
  PRINT "-----------------"
  PRINT

  DO : k$ = INKEY$ : LOOP UNTIL k$ = ""
  PRINT "Enter Callsign:"
  INPUT callsign$
  callsign$ = Clean$(callsign$)

  DO : k$ = INKEY$ : LOOP UNTIL k$ = ""
  PRINT
  PRINT "Enter RST Sent:"
  INPUT rst$
  rst$ = Clean$(rst$)

  DO : k$ = INKEY$ : LOOP UNTIL k$ = ""
  PRINT
  PRINT "Enter Notes (optional):"
  INPUT notes$
  notes$ = Clean$(notes$)

  qso_count = qso_count + 1
  log$(qso_count) = callsign$ + " | RST: " + rst$ + " | Notes: " + notes$ + " | Logged: " + session_date$ + " " + session_time$

  ' Save to file immediately
  ON ERROR SKIP
  OPEN "logbook.txt" FOR APPEND AS #2
  ON ERROR ABORT

  IF MM.ERRNO = 0 THEN
    PRINT #2, log$(qso_count)
    CLOSE #2
  ELSE
    PRINT "Error writing to logbook.txt"
  ENDIF

  PRINT
  PRINT "Contact Logged and Saved!"
  PRINT
  PRINT "Press any key to return to menu..."
  DO : LOOP UNTIL INKEY$ <> ""
END SUB

SUB ShowLogbook
  LOCAL INTEGER i, startpos
  LOCAL INTEGER entries_to_show
  LOCAL STRING k$
  LOCAL INTEGER keycode

  CLS
  PRINT
  PRINT "Logbook Entries"
  PRINT "---------------"
  PRINT

  IF qso_count = 0 THEN
    PRINT "No contacts logged yet."
    PRINT
    PRINT "Press any key to return to menu..."
    DO : LOOP UNTIL INKEY$ <> ""
    EXIT SUB
  ENDIF

  startpos = 1
  entries_to_show = 5

  DO
    CLS
    PRINT "Logbook Entries"
    PRINT "---------------"
    PRINT

    FOR i = startpos TO MIN(startpos + entries_to_show - 1, qso_count)
      PRINT i; ": "; log$(i)
    NEXT i

    PRINT
    PRINT "UP/DOWN to scroll, ENTER to return"

    DO
      k$ = INKEY$
    LOOP UNTIL k$ <> ""

    keycode = ASC(k$)

    IF keycode = 128 THEN
      ' UP
      startpos = startpos - 1
      IF startpos < 1 THEN startpos = 1
    ELSEIF keycode = 129 THEN
      ' DOWN
      startpos = startpos + 1
      IF startpos > qso_count - entries_to_show + 1 THEN startpos = qso_count - entries_to_show + 1
      IF startpos < 1 THEN startpos = 1
    ELSEIF keycode = 10 THEN
      ' ENTER
      EXIT SUB
    ENDIF

  LOOP
END SUB


SUB ShowBackupInstructions
  CLS
  PRINT
  PRINT "Backup Instructions"
  PRINT "-------------------"
  PRINT
  PRINT "1) Connect PicoCalc via USB."
  PRINT "2) Open Thonny or File Manager."
  PRINT "3) Download 'logbook.txt'."
  PRINT
  PRINT "Press any key to return to menu..."
  DO : LOOP UNTIL INKEY$ <> ""
END SUB

SUB EditContact
  LOCAL INTEGER n, i

  CLS
  PRINT
  PRINT "Edit a Contact"
  PRINT "--------------"
  PRINT

  IF qso_count = 0 THEN
    PRINT "No contacts logged yet."
    PRINT
    PRINT "Press any key to return to menu..."
    DO : LOOP UNTIL INKEY$ <> ""
    EXIT SUB
  ENDIF

  FOR n = 1 TO qso_count
    PRINT n; ": "; log$(n)
  NEXT n

  PRINT
  DO : k$ = INKEY$ : LOOP UNTIL k$ = ""
  INPUT "Enter contact number to edit: ", n

  IF n < 1 OR n > qso_count THEN
    PRINT
    PRINT "Invalid contact number."
    PRINT "Press any key to return to menu..."
    DO : LOOP UNTIL INKEY$ <> ""
    EXIT SUB
  ENDIF

  PRINT
  PRINT "Editing Contact #"; n
  PRINT

  DO : k$ = INKEY$ : LOOP UNTIL k$ = ""
  PRINT "Enter new Callsign:"
  INPUT callsign$
  callsign$ = Clean$(callsign$)

  DO : k$ = INKEY$ : LOOP UNTIL k$ = ""
  PRINT
  PRINT "Enter new RST Sent:"
  INPUT rst$
  rst$ = Clean$(rst$)

  DO : k$ = INKEY$ : LOOP UNTIL k$ = ""
  PRINT
  PRINT "Enter new Notes (optional):"
  INPUT notes$
  notes$ = Clean$(notes$)

  log$(n) = callsign$ + " | RST: " + rst$ + " | Notes: " + notes$ + " | Logged: " + session_date$ + " " + session_time$

  ' Save full updated logbook
  ON ERROR SKIP
  OPEN "logbook.txt" FOR OUTPUT AS #2
  ON ERROR ABORT

  IF MM.ERRNO = 0 THEN
    FOR i = 1 TO qso_count
      PRINT #2, log$(i)
    NEXT i
    CLOSE #2
  ELSE
    PRINT "Error writing to logbook.txt"
  ENDIF

  PRINT
  PRINT "Contact Updated and Saved!"
  PRINT
  PRINT "Press any key to return to menu..."
  DO : LOOP UNTIL INKEY$ <> ""
END SUB

' --- Main Program Loop ---

DrawMenu

DO
  k$ = INKEY$

  IF k$ <> "" THEN
    keycode = ASC(k$)

    IF keycode = 128 THEN
      ' UP
      selected = selected - 1
      IF selected < 1 THEN selected = 5
      DrawMenu
    ELSEIF keycode = 129 THEN
      ' DOWN
      selected = selected + 1
      IF selected > 5 THEN selected = 1
      DrawMenu
    ELSEIF keycode = 49 THEN
      LogContact
      DrawMenu
    ELSEIF keycode = 50 THEN
      ShowLogbook
      DrawMenu
    ELSEIF keycode = 51 THEN
      ShowBackupInstructions
      DrawMenu
    ELSEIF keycode = 52 THEN
      EditContact
      DrawMenu
    ELSEIF keycode = 53 THEN
      CLS
      PRINT
      PRINT "Goodbye & 73 from M0MNF!"
      END
    ELSEIF keycode = 10 THEN
      ' ENTER pressed
      SELECT CASE selected
        CASE 1
          LogContact
        CASE 2
          ShowLogbook
        CASE 3
          ShowBackupInstructions
        CASE 4
          EditContact
        CASE 5
          CLS
          PRINT
          PRINT "Goodbye & 73 from M0MNF!"
          END
      END SELECT
      DrawMenu
    ENDIF
  ENDIF

LOOP
