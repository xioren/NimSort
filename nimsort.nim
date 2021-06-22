import std/[posix, terminal]
from os import sleep
from sequtils import count
from random import rand, randomize


# NOTE: all algorithms are in place variants written with terminal display in mind, not efficiency.


##################################
# consts and utils
##################################

const
  barFill = "#"
  sigwinch = 28.cint
  # NOTE: these values are still getting dialed in
  bubbleDelay = 1
  shakerDelay = 1
  selectionDelay = 1
  insertionDelay = 1
  mergeDelay = 25
  shellDelay = 40
  gnomeDelay = 1
  quickDelay = 20

var
  (width, height) = terminalSize()
  resized: bool
  algo: string

type EKeyboardInterrupt = object of CatchableError


proc handler() {.noconv.} =
  raise newException(EKeyboardInterrupt, "Keyboard Interrupt")


proc drawBar(idx, val: int, color=fgDefault) =
  for n in 1..height:
    setCursorPos(idx, n)
    if n < height - val:
      stdOut.write(' ')
    else:
      stdOut.styledWrite(color, barFill)


proc display(data: seq[int], bounds: openarray[int], currentIndex, lookAhead: int) =
  # idead: consider starting at 1, 1 and printing 1 char at a time using x, y as indexes for data
  stdOut.eraseLine()
  stdOut.writeLine('<', algo, '>')
  for idx, val in data:
    if idx in bounds:
      drawBar(idx, val, fgGreen)
    elif idx == currentIndex:
      drawBar(idx, val, fgBlue)
    elif idx == lookAhead:
      drawBar(idx, val, fgRed)
    else:
      drawBar(idx, val)
    stdOut.flushFile()
  stdOut.setCursorPos(0, 0)


proc displayFill(data: seq[int]) =
  stdOut.eraseLine()
  stdOut.writeLine('<', algo, '>')
  for n in 0..data.len:
    for idx, val in data:
      if idx <= n:
        drawBar(idx, val, fgGreen)
      else:
        drawBar(idx, val)
    sleep(5)
  stdOut.setCursorPos(0, 0)
  sleep(250)


proc populate(data: var seq[int]) =
  ## populate data
  for n in 0..<width:
    data[n] = rand(1..<height)


##################################
# sorting algorithms
##################################


proc bubbleSort(data: var seq[int]): bool =
  var current, upperBound: int
  for i in 0..<data.high:
    upperBound = data.high - i
    for j in 0..<upperBound:
      if data[j] > data[succ(j)]:
        current = succ(j)
        swap(data[j], data[succ(j)])
      display(data, [upperBound], j, current)
      if resized:
        return
      sleep(bubbleDelay)
  result = true


proc shakerSort(data: var seq[int]): bool =
  var current, upperBound: int
  for i in 0..<int(data.high / 3):
    upperBound = data.high - i
    for j in i..<upperBound:
      if data[j] > data[succ(j)]:
        current = succ(j)
        swap(data[j], data[succ(j)])
      display(data, [i, upperBound], j, current)
      if resized:
        return
      sleep(shakerDelay)
    for k in countdown(pred(upperBound), succ(i)):
      if data[k] < data[pred(k)]:
        current = pred(k)
        swap(data[k], data[pred(k)])
      display(data, [i, upperBound], k, current)
      if resized:
        return
      sleep(shakerDelay)
  result = true


proc selectionSort(data: var seq[int]): bool =
  var select: int
  for n in 0..data.high:
    select = n
    for i in n..data.high:
      if data[i] < data[select]:
        select = i
      display(data, [n], i, select)
      if resized:
        return
      sleep(selectionDelay)
    swap(data[select], data[n])
  result = true


proc insertionSort(data: var seq[int]): bool =
  var index: int
  for i in 1..data.high:
    index = i
    while index > 0 and data[pred(index)] > data[index]:
      swap(data[pred(index)], data[index])
      dec index
      display(data, [i], index, -1)
      if resized:
        return
      sleep(insertionDelay)
  result = true


proc mergeSort(data: var seq[int], s, e: int): bool =
  if resized:
    return
  proc merge(data: var seq[int], s, m, e: int): bool =
    let
      left = data[s..<m]
      right = data[m..<e]
    var i, j: int

    for l in s..<e:
      if j >= right.len or (i < left.len and left[i] < right[j]):
        data[l] = left[i]
        inc i
      else:
        data[l] = right[j]
        inc j
      display(data, [s, e], l, -1)
      if resized:
        return
      sleep(mergeDelay)
    result = true

  if e - s > 1:
    let mid = int((s + e) / 2)
    discard mergeSort(data, s, mid)
    discard mergeSort(data, mid, e)
    result = merge(data, s, mid, e)


proc shellSort(data: var seq[int]): bool =
  const gaps = [701, 301, 132, 57, 23, 10, 4, 1]
  var j, insertValue: int

  for gap in gaps:
    for i in gap..data.high:
      insertValue = data[i]
      j = i
      while j >= gap and data[j - gap] > insert_value:
        data[j] = data[j - gap]
        j.dec(gap)
        display(data, [gap], i, j)
        if resized:
          return
        sleep(shellDelay)
      if j != i:
        data[j] = insertValue
  result = true


proc gnomeSort(data: var seq[int]): bool =
  var i = 1

  while i < data.len:
    if data[i - 1] <= data[i]:
      inc i
    else:
      swap(data[pred(i)], data[i])
      if i > 1:
        dec i
    display(data, [], i, pred(i))
    if resized:
      return
    sleep(gnomeDelay)
  result = true


proc quickSort(data: var seq[int], st, en: int): bool =
  # FIXME: poorly visualized
  if en > st:
    let pivot = data[en]
    var border = st
    for i in st..<en:
      if data[i] < pivot:
        swap(data[i], data[border])
        inc border
      display(data, [en, st], i, border)
      if resized:
        return
      sleep(quickDelay)
    swap(data[en], data[border])
    discard quickSort(data, st, pred(border))
    discard quickSort(data, succ(border), en)
  result = true


##################################
# main
##################################


proc main() =
  var
    completed: bool
    data: seq[int]
  while true:
    if resized:
      resized = false
      (width, height) = terminalSize()
    randomize()
    newSeq(data, width)
    populate(data)

    let roll = rand(0..7)
    case roll
    of 0:
      algo = "bubble sort"
      completed = bubbleSort(data)
    of 1:
      algo = "shaker sort"
      completed = shakerSort(data)
    of 2:
      algo = "selection sort"
      completed = selectionSort(data)
    of 3:
      algo = "insertion sort"
      completed = insertionSort(data)
    of 4:
      algo = "merge sort"
      completed = mergeSort(data, 0, data.len)
    of 5:
      algo = "shell sort"
      completed = shellSort(data)
    of 6:
      algo = "gnome sort"
      completed = gnomeSort(data)
    of 7:
      algo = "quick sort"
      completed = quickSort(data, 0, data.high)
    else:
      # NOTE: can't happen
      doAssert false
    if completed:
      displayFill(data)


when isMainModule:
  onSignal(sigwinch):
    resized = true
  setControlCHook(handler)
  var exception: string
  try:
    stdOut.hideCursor()
    main()
  except EKeyboardInterrupt:
    discard
  except Exception as e:
    exception = e.msg
  finally:
    stdOut.eraseScreen()
    stdOut.setCursorPos(0, 0)
    stdOut.showCursor()
    if exception != "":
      echo exception
