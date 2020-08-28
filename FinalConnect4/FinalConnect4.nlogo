globals [
  boardState
  temp
  turn
  tempColMouse
  RowCount
  ColCount
  winner
  gameOver
  computerMove
  chipColor
  move
  mousexcor
  tempxcor
  height1
  human1
  player2
  hiddenpointer
  boardScore
  bestCol
  bestScore
  columnbest
  boardSavesList
]

patches-own [ height columnPatch ]

to setup
  ca
  opening
  boardSetup
  ask patches [ set height 0 ]
  set RowCount 6
  set ColCount 7
  set turn 0
  set move 0
  set human1 1
  set player2 2
  set boardState n-values 42 [0]
  set boardSavesList [ ]
  set boardsaveslist lput (boardstate) boardsaveslist
  output-print "###############################"
  output-print "            History            "
  output-print "###############################"
  output-print "     1 is red. 2 is yellow.   "
  output-print "The larger the evaluation the "
  output-print "more the state of the board is"
  output-print "in the favor of the yellow"
  output-print "            player.          ."
end

to opening
  ca
  import-drawing "ONIK.png"
  wait 1
  ;user-message "ERROR. Your computer is frozen. Click OK to continue."
  while [not mouse-down?]
  [import-drawing "connect4.jpg"]
  wait 0.5
  ca
end

to history
  output-print "_______________________________"
  output-print " "
  output-print word "Move " (word move ": ")
  output-print word "Evaluation: " (evaluate boardstate)
  output-print sublist boardstate 0 7
  output-print sublist boardstate 7 14
  output-print sublist boardstate 14 21
  output-print sublist boardstate 21 28
  output-print sublist boardstate 28 35
  output-print sublist boardstate 35 42
  output-print " "
end

to boardSetup
  ca
  ask patches [
	set pcolor 95
	set height 0
  ]
  cro 1 [ set color chipColor set ycor 6 set xcor 0 set shape "pointer" set size 0.8]
  ask patches with [ pycor != 6 ] [ sprout 1 [set color 9.99 set shape "hole" set size 0.8]]
  ask patches with [ pycor >= 6 ] [ set pcolor white]
  ;cro 1 [ set shape "text" set label move set label move setxy 6 6 set label-color black set size 0.0001]
end

to go
  if gameover = 0 [
  ;ask turtles with [ shape = "text" ] [ set label move ]
   ask turtle 0 [
	 set hiddenpointer 0 hidePointer set xcor round mouse-xcor
      ifelse turn = 0 [ set color red ] [ set color yellow ]
  ] ]
  if mouse-down? and turn = 0 and gameover = 0 [
    set tempColMouse round mouse-xcor
    if (member? tempColMouse possiblemoves boardstate)
    [
      set boardstate colplay boardstate 1 tempColMouse
      set turn turn + 1
      set turn turn mod 2
      set move move + 1
	;ask turtles with [ shape = "text" ] [ set label move ]
      history
      if any? turtles with [ shape = "pointer" ] [set mousexcor [xcor] of turtle 0]
      dropChip tempColMouse 1
      if rwin? boardstate [
        ask one-of turtles with [ shape = "redchip" ]
        [ while [size < 25 ] [ ask other turtles in-radius (size / 2) [ set hidden? true ] wait 0.0035 set size size + 0.1 ] ]
        endSceneRed set gameover 1 set winner 1 wait 10 setup
      ]
      draw
    ]
	wait 0.3
	]
  if mouse-down? and turn = 1 and not vsComputer and gameover = 0 [
    set tempColMouse round mouse-xcor
    if (member? tempColMouse possiblemoves boardstate)
    [
      set boardstate colplay boardstate player2 tempColMouse
	set turn turn + 1
	set turn turn mod 2
      set move move + 1
	;ask turtles with [ shape = "text" ] [ set label move ]
      history
      if any? turtles with [ shape = "pointer" ] [set mousexcor [xcor] of turtle 0]
      dropChip tempColMouse 2
      if ywin? boardstate [ ask one-of turtles with [ shape = "yellowchip" ]
        [ while [size < 25 ] [ ask other turtles in-radius (size / 2) [ set hidden? true ] wait 0.0035 set size size + 0.1 ] ]
        endSceneYellow set gameover 1 set winner 2 wait 10 setup
      ]
      draw
    ]
    wait 0.3
  ]
  if turn = 1 and vsComputer and gameover = 0 [
    comMoveCalc
  set boardstate colplay boardstate player2 computerMove
  set turn turn + 1
  set turn turn mod 2
    set move move + 1
  ;ask turtles with [ shape = "text" ] [ set label move ]
    history
    dropchip computerMove 2
    if ywin? boardstate [ ask one-of turtles with [ shape = "yellowchip" ]
      [ while [size < 50 ]
      [ ask other turtles in-radius (size / 2) [ set hidden? true ] wait 0.0035 set size size + 0.1 ] ]
        endSceneYellow set gameover 1 set winner 2 wait 10 setup
      ]
    draw
    wait 0.3
  ]
end

to dropChip [ col piece ]
  if piece = human1 [
    if [height] of patch col 0 < 6
    [
    ask patch col 6 [
  		  sprout 1 [
 		 set shape "redchip"
 		 set size 0.8
 		 set heading 180
   	 while [ycor > [ height] of patch col 0 ]
   	 [fd 0.25 wait 0.01 set hiddenPointer 1 hidePointer]
   	 ask patches with [ pxcor = col ] [ set height height + 1 ]
  ] ] ] ]
  if piece = player2 [
	 if [height] of patch col 0 < 6
    [
      ask patch col 6 [
  		  sprout 1 [
 		 set shape "yellowchip"
 		 set size 0.8
 		 set heading 180
   	 while [ycor > [ height] of patch col 0]
   	 [fd 0.25 wait 0.01 set hiddenPointer 1 hidePointer]
   	 ask patches with [ pxcor = col ] [ set height height + 1 ]
  ] ] ] ]

end

to hidePointer
  if any? turtles with [ shape = "pointer" ] [
    ifelse hiddenpointer = 1
  [ ask turtle 0 [ set hidden? true] ]
    [ ask turtle 0 [ set hidden? false] ] ]
end

to endSceneRed
  ask turtles [ die ]
  ask patches [ set pcolor 15 ]
  import-drawing "redwinner.png"
  set gameover 1
end

to endSceneYellow
  ask turtles [ die ]
  ask patches [ set pcolor 45 ]
  import-drawing "yellowwinner.png"
  set gameover 1
end

to draw
  if move = 42 and gameover = 0
  [ ask turtles [die] import-drawing "draw.png" set gameover 1 ask patches [set pcolor white ]]
end

;####################
;Check For 4 in a row
;####################
; Horizontal Win Check
to rHorizontal [ board ]
  set winner 0
  let col (range 4)
  let row (range 6)
  (foreach col [ [a] -> let colTemp a foreach row [ [b] -> if item pos colTemp b board = 1 and item pos (colTemp + 1) b board = 1 and item pos (colTemp + 2) b board = 1 and item pos (colTemp + 3) b board = 1
    [ set winner 1] ] ])
end

to yHorizontal [ board ]
  set winner 0
  let col (range 4)
  let row (range 6)
  (foreach col [ [a] -> let colTemp a foreach row [ [b] -> if item pos colTemp b board = player2 and item pos (colTemp + 1) b board = player2 and item pos (colTemp + 2) b board = player2 and item pos (colTemp + 3) b board = player2
    [ set winner player2 ] ] ])
end

; Vertical Win Check
to rVertical [ board ]
  set winner 0
  let col (range 7)
  let row (range 3)
  (foreach col [ [a] -> let colTemp a foreach row [ [b] -> if item pos colTemp b board = human1 and item pos colTemp (b + 1) board = human1 and item pos colTemp (b + 2) board = human1 and item pos colTemp (b + 3) board = human1
    [ set winner human1 ] ] ])
end

to yVertical [ board ]
  set winner 0
  let col (range 7)
  let row (range 3)
  (foreach col [ [a] -> let colTemp a foreach row [ [b] -> if item pos colTemp b board = player2 and item pos colTemp (b + 1) board = player2 and item pos colTemp (b + 2) board = player2 and item pos colTemp (b + 3) board = player2
    [ set winner player2 ] ] ])
end

; Direct Diag
to rDirect [ board ]
  set winner 0
  let index [ 21 22 23 24 28 29 30 31 35 36 37 38 ]
  (foreach index [ [a] -> if item a board = human1 and item (a - 6) board = human1 and item (a - 12) board = human1 and item (a - 18) board = human1
    [ set winner human1 ] ])
end

to yDirect [ board ]
  set winner 0
  let index [ 21 22 23 24 28 29 30 31 35 36 37 38 ]
  (foreach index [ [a] -> if item a board = player2 and item (a - 6) board = player2 and item (a - 12) board = player2 and item (a - 18) board = player2
    [ set winner player2 ] ])
end

; Indirect Diag
to rIndirect [ board ]
  set winner 0
  let index [ 0 1 2 3 7 8 9 10 14 15 16 17 ]
  (foreach index [ [a] -> if item a board = human1 and item (a + 8) board = human1 and item (a + 16) board = human1 and item (a + 24) board = human1
    [ set winner human1 ] ])
end

to yIndirect [ board ]
  set winner 0
  let index [ 0 1 2 3 7 8 9 10 14 15 16 17 ]
  (foreach index [ [a] -> if item a board = player2 and item (a + 8) board = player2 and item (a + 16) board = player2 and item (a + 24) board = player2
    [ set winner player2 ] ])
end

; Column Play
to-report colPlay [ board piece col ]
  auxcolumnPlay board piece col 5
  report temp
end

to auxcolumnPlay [ board piece col row]
if row >= 0 [
   ifelse item pos col row board = 0
  	[set temp replace-item (pos col row) board piece]
  	[auxcolumnPlay board piece col (row - 1)]
  ]
end

to-report valPos [ col row board ]
report item (pos col row) board
end

to-report pos [ col row ]
report 7 * row + col
End

to-report possibleMoves [ board ]
  let tempList [ ]
    if item 0 board = 0
    [ set templist lput 0 templist]
    if item 1 board = 0
    [ set templist lput 1 templist]
    if item 2 board = 0
    [ set templist lput 2 templist]
    if item 3 board = 0
    [ set templist lput 3 templist]
    if item 4 board = 0
    [ set templist lput 4 templist]
    if item 5 board = 0
    [ set templist lput 5 templist]
    if item 6 board = 0
    [ set templist lput 6 templist]
   report tempList
end

to comMoveCalc
  let score minimax boardState (difficulty * 2 ) -1000000000000000 1000000000000000 1
  set computermove columnBest
end

; AI

to-report yWin? [ board ]
  yDirect board
  ifelse winner = player2
  [ report true]
  [ yIndirect board
  ifelse winner = player2
    [ report true ]
    [yHorizontal board
      ifelse winner = player2
      [report true]
      [yVertical board
   	 ifelse winner = player2
   	 [report true]
   	 [ report false ] ]]]
end

to-report rWin? [ board ]
  rDirect board
  ifelse winner = human1
  [ report true]
  [ rIndirect board
  ifelse winner = human1
    [ report true ]
    [rHorizontal board
      ifelse winner = human1
      [report true]
      [rVertical board
   	 ifelse winner = human1
   	 [report true]
   	 [ report false ] ]]]
end


to-report minimax [board depth alpha beta maximizingPlayer]
  if alpha < beta [
  ifelse depth = 0 or empty? possiblemoves board or ywin? board or rwin? board
  [ report evaluate board ]
  [ ifelse maximizingPlayer = 1
    [ ;Maximizing Player
      let score -1000000000000000
      set columnBest one-of (possiblemoves board)
      foreach possiblemoves board [ a ->
   	 let bCopy colPlay board 2 a
   	 let nextscore (minimax bCopy (depth - 1) alpha beta 0 )
   	 if nextscore > score
   	 [ set score nextscore
 		 set columnBest a ]
   	 set alpha max list score alpha
   	 ]
      report score
      ]
    [ ;MinimizingPlayer
      let score 1000000000000000
      let tempMoves possiblemoves board
      set columnBest one-of tempMoves
      foreach tempMoves [ a ->
   	 let bCopy colPlay board 1 a
   	 let nextscore (minimax bCopy (depth - 1) alpha beta 1)
   	 if nextscore < score
   	 [ set score nextscore
 		 set columnBest a ]
   	 set alpha max list score alpha
      ]
      report score
    ]
  ]
  ]
end

to-report evaluate [ board ]
  set boardScore 0
  if yWin? board
  [ set boardScore boardScore + 1000000000000]
  if rWin? board
  [ set boardScore boardScore - 1000000000000]
  set boardscore boardscore + (100 * ( (ycenter board - rcenter board )))
  set boardscore boardscore + (1500 * (threeRowEven player2 board - ((threeRowOdd human1 board))))
  set boardscore boardscore + (1000 * (threeRowOdd player2 board - ((threeRowEven human1 board))))
  set boardscore boardscore + (30 * (twoRow player2 board - twoRow human1 board))
  report boardScore
end

to-report threeRowHorEven [ piece board ]
  let numthree 0
  (foreach [ 0 1 2 3 ] [ a -> let coltemp a (foreach [1 3 5] [ b ->
      let templist [ ]
      if item (pos coltemp b) board = piece or item (pos coltemp b) board = 0
      [ set templist fput (item (pos coltemp b) board) templist ]
      if item (pos (coltemp + 1) b) board = piece or item (pos (coltemp + 1) b) board = 0
      [ set templist fput item (pos (coltemp + 1) b) board templist ]
      if item pos (coltemp + 2) b board = piece or item pos (coltemp + 2) b board = 0
      [ set templist fput item pos (coltemp + 2) b board templist ]
      if item pos (coltemp + 3) b board = piece or item pos (coltemp + 3) b board = 0
      [ set templist fput item pos (coltemp + 3) b board templist ]
      if length filter [ ? -> ? = piece ] templist  = 3 and length filter [ ? -> ? = 0 ] (templist) = 1
      [ set numthree numthree + 1 ] ]) ])
  report NumThree
end

to-report threeRowHorOdd [ piece board ]
  let numthree 0
  (foreach [ 0 1 2 3 ] [ a -> let coltemp a (foreach [ 0 2 4 ] [ b ->
      let templist [ ]
      if item (pos coltemp b) board = piece or item (pos coltemp b) board = 0
      [ set templist fput (item (pos coltemp b) board) templist ]
      if item (pos (coltemp + 1) b) board = piece or item (pos (coltemp + 1) b) board = 0
      [ set templist fput item (pos (coltemp + 1) b) board templist ]
      if item pos (coltemp + 2) b board = piece or item pos (coltemp + 2) b board = 0
      [ set templist fput item pos (coltemp + 2) b board templist ]
      if item pos (coltemp + 3) b board = piece or item pos (coltemp + 3) b board = 0
      [ set templist fput item pos (coltemp + 3) b board templist ]
      if length filter [ ? -> ? = piece ] templist  = 3 and length filter [ ? -> ? = 0 ] (templist) = 1
      [ set numthree numthree + 1 ] ]) ])
  report NumThree
end

to-report threeRowVerEven [ piece board ]
  let numthree 0
  (foreach [0 1 2 3 4 5 6 ] [ a -> let coltemp a (foreach [1] [ b ->
      let templist [ ]
      if item pos coltemp b board = piece or item (pos coltemp b) board = 0
      [ set templist fput (item (pos coltemp b) board) templist ]
      if item pos coltemp (1 + b) board = piece or item pos coltemp (1 + b) board = 0
      [ set templist fput item (pos coltemp (1 + b)) board templist ]
      if item pos coltemp (2 + b) board = piece or item pos coltemp (2 + b) board = 0
      [ set templist fput item pos coltemp (2 + b) board templist ]
      if item pos coltemp (3 + b) board = piece or item pos coltemp (3 + b) board = 0
      [ set templist fput item pos coltemp (3 + b) board templist ]
      if length filter [ ? -> ? = piece ] templist  = 3 and length filter [ ? -> ? = 0 ] (templist) = 1
      [ set numthree numthree + 1 ] ]) ] )
  report numthree
end

to-report threeRowVerOdd [ piece board ]
  let numthree 0
  (foreach [0 1 2 3 4 5 6 ] [ a -> let coltemp a (foreach [ 0 2 ] [ b ->
      let templist [ ]
      if item pos coltemp b board = piece or item (pos coltemp b) board = 0
      [ set templist fput (item (pos coltemp b) board) templist ]
      if item pos coltemp (1 + b) board = piece or item pos coltemp (1 + b) board = 0
      [ set templist fput item (pos coltemp (1 + b)) board templist ]
      if item pos coltemp (2 + b) board = piece or item pos coltemp (2 + b) board = 0
      [ set templist fput item pos coltemp (2 + b) board templist ]
      if item pos coltemp (3 + b) board = piece or item pos coltemp (3 + b) board = 0
      [ set templist fput item pos coltemp (3 + b) board templist ]
      if length filter [ ? -> ? = piece ] templist  = 3 and length filter [ ? -> ? = 0 ] (templist) = 1
      [ set numthree numthree + 1 ] ]) ] )
  report numthree
end

to-report threeRowDirectOdd [ piece board ]
  let numthree 0
  let index [ 21 22 23 24 35 36 37 38 ]
  (foreach index [ [a] ->
    let templist [ ]
    if item a board = piece or item a board = 0
    [ set templist fput (item a board) templist ]
    if item (a - 6) board = piece or item (a - 6) board = 0
    [ set templist fput (item (a - 6) board) templist ]
    if item (a - 12) board = piece or item (a - 12) board = 0
    [ set templist fput (item (a - 12) board) templist ]
    if item (a - 18) board = piece or item (a - 18) board = 0
    [ set templist fput (item (a - 18) board) templist ]
    if length filter [ ? -> ? = piece ] templist  = 3 and length filter [ ? -> ? = 0 ] (templist) = 1
    [ set numthree numthree + 1 ] ]
  )
  report numthree
end

to-report threeRowDirectEven [ piece board ]
  let numthree 0
  let index [ 28 29 30 31 ]
  (foreach index [ [a] ->
    let templist [ ]
    if item a board = piece or item a board = 0
    [ set templist fput (item a board) templist ]
    if item (a - 6) board = piece or item (a - 6) board = 0
    [ set templist fput (item (a - 6) board) templist ]
    if item (a - 12) board = piece or item (a - 12) board = 0
    [ set templist fput (item (a - 12) board) templist ]
    if item (a - 18) board = piece or item (a - 18) board = 0
    [ set templist fput (item (a - 18) board) templist ]
    if length filter [ ? -> ? = piece ] templist  = 3 and length filter [ ? -> ? = 0 ] (templist) = 1
    [ set numthree numthree + 1 ] ]
  )
  report numthree
end

to-report threeRowIndirectEven [ piece board ]
  let numthree 0
  let index [ 0 1 2 3 7 8 9 10 14 15 16 17 ]
  (foreach index [ [a] ->
    let templist [ ]
    if item a board = piece or item a board = 0
    [ set templist fput (item a board) templist ]
    if item (a + 8) board = piece or item (a + 8) board = 0
    [ set templist fput (item (a + 8) board) templist ]
    if item (a + 16) board = piece or item (a + 16) board = 0
    [ set templist fput (item (a + 16) board) templist ]
    if item (a + 24) board = piece or item (a + 24) board = 0
    [ set templist fput (item (a + 24) board) templist ]
    if length filter [ ? -> ? = piece ] templist  = 3 and length filter [ ? -> ? = 0 ] (templist) = 1
    [ set numthree numthree + 1 ] ]
  )
  report numthree
end

to-report threeRowIndirectOdd [ piece board ]
  let numthree 0
  let index [ 7 8 9 10 ]
  (foreach index [ [a] ->
    let templist [ ]
    if item a board = piece or item a board = 0
    [ set templist fput (item a board) templist ]
    if item (a + 8) board = piece or item (a + 8) board = 0
    [ set templist fput (item (a + 8) board) templist ]
    if item (a + 16) board = piece or item (a + 16) board = 0
    [ set templist fput (item (a + 16) board) templist ]
    if item (a + 24) board = piece or item (a + 24) board = 0
    [ set templist fput (item (a + 24) board) templist ]
    if length filter [ ? -> ? = piece ] templist  = 3 and length filter [ ? -> ? = 0 ] (templist) = 1
    [ set numthree numthree + 1 ] ]
  )
  report numthree
end

to-report threeRowEven [ piece board ]
  report threeRowHorEven piece board + threeRowVerEven piece board + threeRowDirectEven piece board + threeRowIndirectEven piece board
end

to-report threeRowOdd [ piece board ]
  report threeRowHorOdd piece board + threeRowVerOdd piece board + threeRowDirectOdd piece board + threeRowIndirectOdd piece board
end

to-report twoRowHor [ piece board ]
  let numthree 0
  (foreach [ 0 1 2 3 ] [ a -> let coltemp a (foreach [ 0 1 2 3 4 5 ] [ b ->
      let templist [ ]
      if item (pos coltemp b) board = piece or item (pos coltemp b) board = 0
      [ set templist fput (item (pos coltemp b) board) templist ]
      if item (pos (coltemp + 1) b) board = piece or item (pos (coltemp + 1) b) board = 0
      [ set templist fput item (pos (coltemp + 1) b) board templist ]
      if item pos (coltemp + 2) b board = piece or item pos (coltemp + 2) b board = 0
      [ set templist fput item pos (coltemp + 2) b board templist ]
      if item pos (coltemp + 3) b board = piece or item pos (coltemp + 3) b board = 0
      [ set templist fput item pos (coltemp + 3) b board templist ]
      if length filter [ ? -> ? = piece ] templist  = 2 and length filter [ ? -> ? = 0 ] (templist) = 2
      [ set numthree numthree + 1 ] ]) ])
  report NumThree
end

to-report twoRowVer [ piece board ]
  let numthree 0
  (foreach [0 1 2 3 4 5 6 ] [ a -> let coltemp a (foreach [ 0 1 2 ] [ b ->
      let templist [ ]
      if item pos coltemp b board = piece or item (pos coltemp b) board = 0
      [ set templist fput (item (pos coltemp b) board) templist ]
      if item pos coltemp (1 + b) board = piece or item pos coltemp (1 + b) board = 0
      [ set templist fput item (pos coltemp (1 + b)) board templist ]
      if item pos coltemp (2 + b) board = piece or item pos coltemp (2 + b) board = 0
      [ set templist fput item pos coltemp (2 + b) board templist ]
      if item pos coltemp (3 + b) board = piece or item pos coltemp (3 + b) board = 0
      [ set templist fput item pos coltemp (3 + b) board templist ]
      if length filter [ ? -> ? = piece ] templist  = 2 and length filter [ ? -> ? = 0 ] (templist) = 2
      [ set numthree numthree + 1 ] ]) ] )
  report numthree
end

to-report twoRowDirect [ piece board ]
  let numthree 0
  let index [ 21 22 23 24 28 29 30 31 35 36 37 38 ]
  (foreach index [ [a] ->
    let templist [ ]
    if item a board = piece or item a board = 0
    [ set templist fput (item a board) templist ]
    if item (a - 6) board = piece or item (a - 6) board = 0
    [ set templist fput (item (a - 6) board) templist ]
    if item (a - 12) board = piece or item (a - 12) board = 0
    [ set templist fput (item (a - 12) board) templist ]
    if item (a - 18) board = piece or item (a - 18) board = 0
    [ set templist fput (item (a - 18) board) templist ]
    if length filter [ ? -> ? = piece ] templist  = 2 and length filter [ ? -> ? = 0 ] (templist) = 2
    [ set numthree numthree + 1 ] ]
  )
  report numthree
end

to-report twoRowIndirect [ piece board ]
  let numthree 0
  let index [ 0 1 2 3 7 8 9 10 14 15 16 17 ]
  (foreach index [ [a] ->
    let templist [ ]
    if item a board = piece or item a board = 0
    [ set templist fput (item a board) templist ]
    if item (a + 8) board = piece or item (a + 8) board = 0
    [ set templist fput (item (a + 8) board) templist ]
    if item (a + 16) board = piece or item (a + 16) board = 0
    [ set templist fput (item (a + 16) board) templist ]
    if item (a + 24) board = piece or item (a + 24) board = 0
    [ set templist fput (item (a + 24) board) templist ]
    if length filter [ ? -> ? = piece ] templist  = 2 and length filter [ ? -> ? = 0 ] (templist) = 2
    [ set numthree numthree + 1 ] ]
  )
  report numthree
end

to-report twoRow [ piece board ]
  report twoRowHor piece board + twoRowVer piece board + twoRowDirect piece board + twoRowIndirect piece board
end

to-report yCenter [ board ]
  let center 0
  (foreach [ 3 10 17 24 31 38 ] [ x ->
    if item x board = 2 [ set center center + 1 ] ] )
  report center
end

to-report rCenter [ board ]
  let center 0
  (foreach [ 3 10 17 24 31 38 ] [ x ->
    if item x board = 1 [ set center center + 1 ] ] )
  report center
end

@#$#@#$#@
GRAPHICS-WINDOW
19
10
485
477
-1
-1
65.43
1
13
1
1
1
0
0
0
1
0
6
0
6
0
0
1
ticks
30.0

BUTTON
493
10
767
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
493
46
767
79
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
493
80
768
113
vsComputer
vsComputer
1
1
-1000

SLIDER
492
116
770
149
difficulty
difficulty
1
2
1.0
1
1
NIL
HORIZONTAL

OUTPUT
494
154
773
475
12

@#$#@#$#@
Shadman Rakib PD. 9
## WHAT IS IT?

This is Connect 4. Connect 4 is a game where you have to connect four chips. When you place a chip, it drops to the lowermost available row. There are 7 columns and 6 rows.
This is both multiplayer and single player.

## HOW IT WORKS

This game is represented as a list. This list is called boardstate. There are procedures that modify the list. This procedure replaces the 0 (free space) with the appropriate number (piece). All this is then represented graphically. There is also a droping feature that allows for the dropping animation as well as the graphics. Each column has its own height. When a piece is played in a column, it increases that columns height by 1. The program makes sure that the move is playable ( seperate procedure ). Four in a row is  checked by looking at all combinations. This was better than checking the last piece because it could be reused for the coumputer evaluation.
The computer player uses a minimax algorithm with alpha-beta pruning. The possible boards are evaluated using the eavluate function. This function takes into account a number of factors that include the computer's and human's number of three in a row, number of two in a row, number of pieces in central column, and odd even threats. All of these facotrs have seperate procedures. The different scences are pictures imported.
The list was the first thing made. It was followed by a method of translating it to graphic. Then, two player was finished. Finally, a single player was introduced.
History is shown in the output by printing sublist of the boardstate as well as other information.

## HOW TO USE IT

If you want to versus the computer, then switch vsComputer to true. Difficulty is how many pairs of step it searches when the minimax is used. To play, click setup, then go, wait for the starting screen to which you click. Then it should show the board. Click over the column you want to play. Make sure not to press for too long or you might register two moves. No need to press setup again as game will restart after 10 seconds following a win or draw.

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(I can add an undo procedure (working on it might not have time to finish).)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

Wikipedia helped me understand minimax and alpha beta pruning. The pseudocode was  helpful.

https://en.wikipedia.org/wiki/Minimax
https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

hole
false
13
Circle -13345367 true false 0 0 300
Circle -1 true false 30 15 270

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

pointer
true
0
Polygon -16777216 true false 150 105 285 75 150 300 15 75
Polygon -7500403 true true 150 135 285 75 150 300 15 75
Line -16777216 false 150 105 150 300
Line -16777216 false 15 75 150 105
Line -16777216 false 150 105 285 75
Line -16777216 false 15 75 150 300
Line -16777216 false 285 75 150 300
Line -16777216 false 150 135 150 300
Line -16777216 false 285 75 150 135
Line -16777216 false 15 75 150 135

redchip
true
0
Circle -2674135 true false 0 0 300
Circle -5825686 true false 45 45 210
Circle -2674135 true false 48 53 196
Rectangle -6459832 true false 150 15 150 45
Circle -5825686 true false 50 226 30
Circle -5825686 true false 225 225 30
Circle -5825686 true false 40 54 30
Circle -5825686 true false 234 54 30
Circle -5825686 true false 9 143 30
Circle -5825686 true false 262 144 30
Circle -5825686 true false 138 263 30
Circle -5825686 true false 133 9 30
Circle -2674135 true false 134 12 24
Circle -2674135 true false 40 57 24
Circle -2674135 true false 10 146 24
Circle -2674135 true false 51 229 24
Circle -2674135 true false 139 266 24
Circle -2674135 true false 226 228 24
Circle -2674135 true false 263 147 24
Circle -2674135 true false 234 57 24

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

text
true
0

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

yellowchip
true
0
Circle -1184463 true false 0 0 300
Circle -6459832 true false 45 45 210
Circle -1184463 true false 48 53 196
Rectangle -6459832 true false 150 15 150 45
Circle -6459832 true false 50 226 30
Circle -6459832 true false 225 225 30
Circle -6459832 true false 40 54 30
Circle -6459832 true false 234 54 30
Circle -6459832 true false 9 143 30
Circle -6459832 true false 262 144 30
Circle -6459832 true false 138 263 30
Circle -6459832 true false 133 9 30
Circle -1184463 true false 134 12 24
Circle -1184463 true false 40 57 24
Circle -1184463 true false 10 146 24
Circle -1184463 true false 51 229 24
Circle -1184463 true false 139 266 24
Circle -1184463 true false 226 228 24
Circle -1184463 true false 263 147 24
Circle -1184463 true false 234 57 24
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
