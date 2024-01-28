import std/[posix, terminal, strutils]
from os import sleep
from random import rand, randomize


type
  Algo = enum
    BubbleSort, CountingSort, GnomeSort, HeapSort, InsertionSort, MergeSort, QuickSort, RadixSort, SelectionSort, ShellSort, ShakerSort
  Frame = seq[seq[int]]
  KeyboardInterrupt = object of CatchableError

const
  fillChar:       string = "#"
  emptyChar:      string = " "
  sigwinch:       cint = 28
  # NOTE: delay constants
  C:              float = 1.7 # higher == slower
  V:              float = 1.0 # higher == faster
  # NOTE: delay constants for algorithms, smaller values == longer delays
  # NOTE: these values are still getting dialed in
  bubbleDelay:    float = 2.0
  countingDelay:  float = 0.5
  heapDelay:      float = 0.2
  gnomeDelay:     float = 1.0
  insertionDelay: float = 0.8
  mergeDelay:     float = 0.4
  quickDelay:     float = 0.5
  radixDelay:     float = 0.1
  shakerDelay:    float = 2.0
  selectionDelay: float = 3.0
  shellDelay:     float = 0.2

var
  (tWidth, tHeight) = terminalSize()
  resized:            bool
  currentFrameBuffer: Frame
  nextFrameBuffer:    Frame
  frameDelta:         Frame
  nextIndices:        array[4, int]
  currentIndices:     array[4, int]



proc interruptHandler() {.noconv.} =
  raise newException(KeyboardInterrupt, "Keyboard Interrupt")


proc calculateDelay(A: float): int =
  return int(max(C / (A * float(tWidth + tHeight) * V), 0.0) * 1000)


proc newRandomData(): seq[int] =
  result = newSeq[int](tWidth)
  randomize()
  for n in 0 ..< tWidth:
    result[n] = rand(1 ..< tHeight)


proc newFrame(): Frame =
  result = newSeq[seq[int]](tWidth)
  for i in 0 ..< tWidth:
    result[i] = newSeq[int](tHeight)
  return result


proc generateColumn(value: int): seq[int] = 
  result = newSeq[int](tHeight)
  for n in 0 ..< tHeight.pred:
    if n < value:
      result[tHeight.pred - n] = 1
    else:
      result[tHeight.pred - n] = 0


proc generateFrame(data: seq[int]): Frame =
  result = newFrame()
  for i, d in data:
    result[i] = generateColumn(d)


proc generateFrameDelta(current, next: Frame): Frame =
  result = newFrame()
  for i, column in next:
    for j, val in column:
      if next[i][j] != current[i][j]:
        if next[i][j] == 0:
          result[i][j] = -1
        else:
          result[i][j] = 1


proc colorizeColumn(x: int, color: ForegroundColor) =
  # DEBUG:
  if x < 0 or x >= tWidth:
    return
    # raise newException(IndexError, "kaboom: $1" % $x)
  for y in 0 .. nextFrameBuffer[x].high:
    if nextFrameBuffer[x][y] == 1:
      setCursorPos(x, y)
      stdOut.styledWrite(color, fillChar)


proc decolorizeColumn(x: int) =
  # DEBUG:
  if x < 0 or x >= tWidth:
    return
    # raise newException(IndexError, "kablam: $1" % $x)
  for y in 0 .. nextFrameBuffer[x].high:
    if nextFrameBuffer[x][y] == 1:
      setCursorPos(x, y)
      stdOut.write(fillChar)


proc drawFrame(frame: Frame) =
  # NOTE: by rows
  for y in 0 ..< tHeight:
    for x in 0 ..< tWidth:
      if frame[x][y] == 1:
        setCursorPos(x, y)
        stdOut.write(fillChar)
      elif frame[x][y] == -1:
        setCursorPos(x, y)
        stdOut.write(emptyChar)
  stdout.flushFile()


proc drawIndices() =
  if nextIndices[0] != -1:
    if nextIndices[0] != currentIndices[0]:
      decolorizeColumn(currentIndices[0])
    colorizeColumn(nextIndices[0], fgGreen)
  if nextIndices[1] != -1:
    if nextIndices[1] != currentIndices[1]:
      decolorizeColumn(currentIndices[1])
    colorizeColumn(nextIndices[1], fgRed)
  if nextIndices[2] != -1:
    if nextIndices[2] != currentIndices[2]:
      decolorizeColumn(currentIndices[2])
    colorizeColumn(nextIndices[2], fgBlue)
  if nextIndices[3] != -1:
    if nextIndices[3] != currentIndices[3]:
      decolorizeColumn(currentIndices[3])
    colorizeColumn(nextIndices[3], fgBlue)
  stdout.flushFile()


proc updateIndices(index, lookAhead, lowerBound, upperBound: int) =
  currentIndices[0] = nextIndices[0]
  currentIndices[1] = nextIndices[1]
  currentIndices[2] = nextIndices[2]
  currentIndices[3] = nextIndices[3]

  nextIndices[0] = index
  nextIndices[1] = lookAhead
  nextIndices[2] = lowerBound
  nextIndices[3] = upperBound


proc clearIndices() =
  for i, idx in nextIndices:
    if idx == -1:
      if currentIndices[i] != -1:
        decolorizeColumn(currentIndices[i])
    else:
      decolorizeColumn(idx)


proc display(data: seq[int], index: int, lookAhead, lowerBound, upperBound: int = -1) =
  if not resized:
    updateIndices(index, lookAhead, lowerBound, upperBound)
    nextFrameBuffer = generateFrame(data)
    frameDelta = generateFrameDelta(currentFrameBuffer, nextFrameBuffer)
    drawFrame(frameDelta)
    drawIndices()
    currentFrameBuffer = nextFrameBuffer


proc displayFill() =
  clearIndices()
  for x in 0 ..< tWidth:
    colorizeColumn(x, fgGreen)
    sleep(5)
  stdout.flushFile()
  sleep(500)


proc writeHeader(algo: Algo) =
  var algoString: string
  case algo
  of BubbleSort:
    algoString = "bubble sort"
  of CountingSort:
    algoString = "counting sort"
  of GnomeSort:
    algoString = "gnome sort"
  of HeapSort:
    algoString = "heap sort"
  of InsertionSort:
    algoString = "insertion sort"
  of MergeSort:
    algoString = "merge sort"
  of QuickSort:
    algoString = "quick sort"
  of RadixSort:
    algoString = "radix sort"
  of SelectionSort:
    algoString = "selection sort"
  of ShellSort:
    algoString = "shell sort"
  of ShakerSort:
    algoString = "shaker sort"

  setCursorPos(0, 0)
  stdOut.eraseLine()
  stdOut.write("<$1>" % algoString)

##################################
# main
##################################

include algorithms

proc main() =
  # TODO: add resize exception
  var
    completed: bool
    algo: Algo
    data: seq[int]
  
  while true:
    if resized:
      resized = false
      (tWidth, tHeight) = terminalSize()
    stdOut.eraseScreen()
    data = newRandomData()
    currentFrameBuffer = newFrame()
    
    let roll = rand(0 .. 10)
    algo = Algo(roll)
    writeHeader(algo)
    case algo
    of BubbleSort:
      completed = bubbleSort(data)
    of CountingSort:
      completed = countingSort(data)
    of GnomeSort:
      completed = gnomeSort(data)
    of HeapSort:
      completed = heapSort(data)
    of InsertionSort:
      completed = insertionSort(data)
    of MergeSort:
      completed = mergeSort(data, 0, data.len)
    of QuickSort:
      completed = quickSort(data, 0, data.high)
    of RadixSort:
      completed = radixSort(data)
    of SelectionSort:
      completed = selectionSort(data)
    of ShakerSort:
      completed = shakerSort(data)
    of ShellSort:
      completed = shellSort(data)
    
    if completed:
      displayFill()
    currentIndices.reset()
    nextIndices.reset()


when isMainModule:
  var exception: string
  onSignal(sigwinch):
    resized = true
  setControlCHook(interruptHandler)

  try:
    stdOut.hideCursor()
    setCursorPos(0, 0)
    main()
  except KeyboardInterrupt:
    discard
  except Exception as e:
    exception = e.msg
  finally:
    stdOut.eraseScreen()
    stdOut.setCursorPos(0, 0)
    stdOut.showCursor()
    # NOTE: echo exception after clearing screen
    if not exception.isEmptyOrWhitespace():
      echo exception
