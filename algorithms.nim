##################################
# helpers
##################################


proc getMax(data: seq[int]): int =
  ## find the maximum value in the array
  result = data[0]
  for i in 1 .. data.high:
    if data[i] > result:
      result = data[i]


##################################
# sorting algorithms
##################################


proc countingSort(data: var seq[int]): bool =
  let maxVal = getMax(data)
  var count = newSeq[int](maxVal.succ)
  var output = newSeq[int](data.len)

  # NOTE: store the count of each element
  for i, x in data:
    if resized:
      return false
    inc count[x]
    display(data, i)
    sleep(calculateDelay(countingDelay))

  # NOTE: change count[i] so that count[i] now contains the actual position of this digit in output[]
  for i in 1 .. maxVal:
    count[i].inc(count[i.pred])

  # NOTE: build the output array
  for i, x in data:
    if resized:
      return false
    output[count[x].pred] = x
    display(data, i, count[x].pred)
    dec count[x]
    sleep(calculateDelay(countingDelay))

  # NOTE: copy the output array to data, so that data now contains sorted numbers
  for i in 0 .. data.high:
    if resized:
      return false
    data[i] = output[i]
    display(data, i)
    sleep(calculateDelay(countingDelay))

  display(data, -1)
  return true


proc countSort(data: var seq[int], exp: int = 1): bool =
  ## radix variation
  let n = data.len
  var output = newSeq[int](n)
  var count = newSeq[int](10)

  # NOTE: store the count of each element
  for i in 0 .. data.high:
    if resized:
      return false
    let index = (data[i] div exp) mod 10
    display(data, i, index, count[index])
    inc count[index]
    sleep(calculateDelay(countingDelay))

  # NOTE: change count[i] so that count[i] now contains the actual position of this digit in output[]
  for i in 1 .. 9:
    count[i].inc(count[i.pred])

  # NOTE: build the output array
  for i in countdown(data.high, 0):
    if resized:
      return false
    let index = (data[i] div exp) mod 10
    output[count[index].pred] = data[i]
    display(data, i, index, count[index].pred, count[index])
    dec count[index]
    sleep(calculateDelay(countingDelay))

  # NOTE: copy the output array to data, so that data now contains sorted numbers
  for i in 0 .. data.high:
    if resized:
      return false
    data[i] = output[i]
    display(data, i)
    sleep(calculateDelay(countingDelay))

  display(data, 1)
  return true


proc bubbleSort(data: var seq[int]): bool =
  var current, upperBound: int
  for i in 0 ..< data.high:
    upperBound = data.high - i
    for j in 0 ..< upperBound:
      if data[j] > data[j.succ]:
        current = j.succ
        swap(data[j], data[current])
      display(data, j, current, upperBound=upperBound)
      if resized:
        return
      sleep(calculateDelay(bubbleDelay))
  result = true


proc gnomeSort(data: var seq[int]): bool =
  var i = 1

  while i < data.len:
    if data[i - 1] <= data[i]:
      inc i
    else:
      swap(data[i.pred], data[i])
      if i > 1:
        dec i
    display(data, i, i.pred)
    if resized:
      return
    sleep(calculateDelay(gnomeDelay))
  result = true


proc heapSort(data: var seq[int]): bool =
  proc heapify(data: var seq[int], n: int, i: int): bool =
    ## heapify a subtree rooted at index i
    if resized:
      return false
    var largest = i        # initialize largest as root
    let left = 2 * i + 1   # left = 2*i + 1
    let right = 2 * i + 2  # right = 2*i + 2

    # NOTE: if left child is larger than root
    if left < n and data[left] > data[largest]:
      largest = left

    # NOTE: if right child is larger than largest so far
    if right < n and data[right] > data[largest]:
      largest = right

    # NOTE: if largest is not root
    if largest != i:
      swap(data[i], data[largest])
      display(data, i, largest)
      sleep(calculateDelay(heapDelay))
      # NOTE: recursively heapify the affected sub-tree
      if not heapify(data, n, largest):
        return false
    
    return true

  # NOTE: build a maxheap
  for i in countdown(data.len div 2 - 1, 0):
    if not heapify(data, data.len, i):
      return false

  # NOTE: one by one extract elements
  for i in countdown(data.len - 1, 1):
    swap(data[0], data[i])       # move current root to end
    if not heapify(data, i, 0):  # call max heapify on the reduced heap
      return false

  display(data, -1)
  return true


proc insertionSort(data: var seq[int]): bool =
  var index: int
  for i in 1 .. data.high:
    index = i
    while index > 0 and data[index.pred] > data[index]:
      swap(data[index.pred], data[index])
      dec index
      display(data, index, upperBound=i)
      if resized:
        return
      sleep(calculateDelay(insertionDelay))
  result = true


proc mergeSort(data: var seq[int], s, e: int): bool =
  if resized:
    return
  proc merge(data: var seq[int], s, m, e: int): bool =
    let
      left = data[s ..< m]
      right = data[m ..< e]
    var i, j: int

    for l in s ..< e:
      if j >= right.len or (i < left.len and left[i] < right[j]):
        data[l] = left[i]
        inc i
      else:
        data[l] = right[j]
        inc j
      display(data, l, lowerBound=s, upperBound=e)
      if resized:
        return
      sleep(calculateDelay(mergeDelay))
    result = true

  if e - s > 1:
    let mid = int((s + e) / 2)
    discard mergeSort(data, s, mid)
    discard mergeSort(data, mid, e)
    result = merge(data, s, mid, e)


proc quickSort(data: var seq[int], st, en: int): bool =
  # TODO: poorly visualized
  if en > st:
    let pivot = data[en]
    var border = st
    for i in st ..< en:
      if data[i] < pivot:
        swap(data[i], data[border])
        inc border
      display(data, i, border, en, st)
      if resized:
        return
      sleep(calculateDelay(quickDelay))
    swap(data[en], data[border])
    discard quickSort(data, st, border.pred)
    discard quickSort(data, border.succ, en)
  result = true


proc radixSort(data: var seq[int]): bool =
  let m = getMax(data)
  var exp = 1
  while m div exp > 0:
    if not countSort(data, exp):
      return false
    exp *= 10
  return true


proc selectionSort(data: var seq[int]): bool =
  var select: int
  for n in 0 .. data.high:
    select = n
    for i in n .. data.high:
      if data[i] < data[select]:
        select = i
      display(data, i, select, upperBound=n)
      if resized:
        return
      sleep(calculateDelay(selectionDelay))
    # QUESTION: should swap be before or after display?
    # TODO: determin for all algos
    swap(data[select], data[n])
  result = true


proc shakerSort(data: var seq[int]): bool =
  var current, upperBound: int
  for i in 0 ..< int(data.high / 3):
    upperBound = data.high - i
    for j in i ..< upperBound:
      if data[j] > data[succ(j)]:
        current = succ(j)
        swap(data[j], data[succ(j)])
      display(data, j, current, i, upperBound)
      if resized:
        return
      sleep(calculateDelay(shakerDelay))
    for k in countdown(pred(upperBound), succ(i)):
      if data[k] < data[pred(k)]:
        current = pred(k)
        swap(data[k], data[pred(k)])
      display(data, k, current, i, upperBound)
      if resized:
        return
      sleep(calculateDelay(shakerDelay))
  result = true


proc shellSort(data: var seq[int]): bool =
  const gaps = [701, 301, 132, 57, 23, 10, 4, 1]
  var j, insertValue: int

  for gap in gaps:
    for i in gap .. data.high:
      insertValue = data[i]
      j = i
      while j >= gap and data[j - gap] > insert_value:
        data[j] = data[j - gap]
        j.dec(gap)
        display(data, i, j, upperBound=gap)
        if resized:
          return
        sleep(calculateDelay(shellDelay))
      if j != i:
        data[j] = insertValue
  result = true