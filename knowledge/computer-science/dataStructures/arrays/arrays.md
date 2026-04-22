# Array and Data Types

## Data Types - Primitive Types

bool 1-byte [true,false] or equivalent [1=false, 0=true]
char 1-byte  [a,b,c,#,!]
double 8-bytes [2.13242]
float 4-bytes [4.1]
int 4-bytes [1,2,3,4]
long 8-bytes [12342532]
string ?-bytes [it can be how much text as you like]
...

All the files, programs, etc (bytes) are stored on RAM (ramdon access memory) which might be consider a volatile memory that needs electricity to function.

So, if we got some simple code on C that gets the average of a student's note

```c
#include <stdio.h>

int main()
{
    int score1 = 72;
    int score2 = 73;
    int score3 = 33;

    printf("Average: %f\n", (score1 + score2 + score3) / 3.0);  // this will get the avrg of the scores
}
```

What this will do underneath the hood is: It will access the RAM for random storing inside the memory (depending on the type of data you're storing [1,2,4,8] bytes).

## ARRAYS

Arrays are consider a contiguous area of memory consisting of equal-size elements indexed by contiguous integers.

But what happens when we need to store all the scores into one "unlimited" congitious list? .

```C
#include <stdio.h>
#include <cs50.h> // this is a library that easen a lot of the operations with int and arrays

const int TOTAL = 3;

int main(void)
{
    int scores[TOTAL];

    for (int i = 0; i<TOTAL; i++);
    {
        scores[i] = get_int("Scores: "); // this is one of the fn from cs50.h that will act like input() from python. Will ask for an int number to be pass on the array
    }

    printf("Average: %f\n", average(TOTAL, scores));
}

float average(int length, int array);
{
    int sum = 0;
    for (int i = 0; i<length; i++)
    {
        sum += array[i];
    }
    return sum / (float) length;
}
main()
```

This is a more "elegant" way of introduction to Arrays. On this code block of C-language we can notice a way to create a dynamic array based on the constant *int TOTAL* found on the beginning of the code. So, we can stored the total amount of the constant so we can work with a dynamic array to store different values inside this list. Thus, increasing the size at will, just by changing the *TOTAL* value.

**PD: This might vary from different proramming languages. Clang is staticly-typed, so we have to know what type of values we're storing inside the array, but for languages like Python or Javascript we can skip these since those languages have the commodities of doing it for you*

```python
def main():
    TOTAL = 3
    scores = []   
    for i in range(TOTAL):
        score = int(input("Score: "))  # Get integer input
        scores.append(score)           # Add to list
    
    print(f"Average: {average(TOTAL, scores)}")


def average(length, array):
    total = 0
    for value in array:      # 'value' is the actual number
        total += value 
    return total / length    # Python 3 division returns float

main()
```

## Multi-dimensional Arrays

Arrays can be organized under diffenrent dimensions such as 2nd_dimensions, 3rd_dimensions, even 4th or 5th_dimensions.  
This can represented on C as:

```C
int myArray[2][2]; // this will create a 2D array with height and width 
```

**Personal note:** It's not that very common for me to see further dimension than the 3rd dimension.  
I've seen so far engineers working 'till the 3rd dimension so:

```c
int array[1][2][3];
```

### Row-major-ordering/indexing

row_major_ordering =
[
    [(1,1)]
    [(1,2)]
    [(1,3)]
    [(2,1)]
    [(2,2)]
    [(2,3)]
]

### Column-major-ordering/indexing

column_major_ordering =
[
    [(1,1)]
    [(2,1)]
    [(3,1)]
    [(1,2)]
    [(2,2)]
    [(3,2)]
]

### Times for Common Operations

So with this table we can say that is cheap to add new elements at the end of the array because there's no processes involved, but it's
expensive to add it to the end or the beginning because we've got to move all the values +1 space or cut them down in the middle previously counting them  
and moving them +1 space to the right or the left.

| Position  | Add  | Remove |
|-----------|------|--------|
| Beginning | O(n) | O(n)   |
| End       | O(1) | O(1)   |
| Middle    | O(n) | O(n)   |

#### Summary for lists

- Array are contiguous area of memory consisting of equal-size elements indexed by contiguous integers.
- Constant-time access to any element.
- Constant-time to add/remove at the end.
- Linear time to add/remove at an arbitrary location

## Linked-List

### Singly-linked-list

#### List API

- PushFront(key)  add to front
- key TopFront()  return from item
- PopFront()      remove front item
- PushBack(key)   add to back
- Key TopBack()   return back item
- PopBack()       remove back item
- Boolean Find(key) is key in list?
- Erase(Key)      remove key from list
- Boolean Empty() empty list?
- AddBefore(Node, Key) adds key before node
- AddAfter(Node, Key) adds key after node

#### Some pseudocode on Singly-linked-lists

##### PushFront(key)

```pseudoce
node <- new node
node.key <- key
node.next <- head
head <- node
if tail = nil:
    tail <- head
```

##### PopFront()

```pseudocode
if head = nil:
    ERROR: empty list
head <- head.next
if head = nil:
    tail <- nil
```

##### PushBack(key)

```pseudocode
node <- new node
node.key <- key
node.next = nil
if tail = nil:
    head <- tail <- node
else:
    tail.next <- node
    tail <- node
```

##### PopBack()

```pseudocode
if head = nil: ERROR: empty list
if head = tail:
    head <- tail <- nil
else:
    p <- head
    while p.next.next != nil:
        p <- p.next
    p.next <- nil; tail <- p
```

##### AddAfter(node, key)

```pseudocode
node2 <- new node
node2.key <- key
node2.next = node.next
node.next = node2
if tail = node:
    tail <- node2
```

### Summary of linked lists

|  Singly-Linked-List  | no tail | with tail |
|:--------------------:|:-------:|:---------:|
|    PushFront(key)    |   O(1)  |           |
|    key TopFront()    |   O(1)  |           |
|      PopFront()      |   O(1)  |           |
|     PushBack(key)    |   O(n)  |    O(1)   |
|     Key TopBack()    |   O(n)  |    O(1)   |
|       PopBack()      |   O(n)  |           |
|   Boolean Find(key)  |   O(n)  |           |
|      Erase(Key)      |   O(n)  |           |
| Boolean Empty()      |   O(1)  |           |
| AddBefore(Node, Key) |   O(n)  |           |
| AddAfter(Node, Key)  |   O(n)  |           |

## Doubly-Linked List

A doubly linked list is a more complex data structure than a singly linked list, but it offers several advantages. The main advantage of a doubly linked list is that it allows for efficient traversal of the list in both directions. This is because each node in the list contains a pointer to the previous node and a pointer to the next node. This allows for quick and easy insertion and deletion of nodes from the list, as well as efficient traversal of the list in both directions.

[doubly-linked-lists-img](img/doubly-linked-list.png)

[head] ->   [7]       [10]    [4]     [13]     [tail]
            [7.node]  [node]  [node]  [node]
            [7.node2] [node2] [node2] [node2]

Where:
    [7.node] -> [10]
    [10.node2] -> [7.node]
    [10.node] -> [4]
    [4.node2] -> [10.node]

**Node Contains:**

- Key
- Next pointer
- Previous pointer

### Some pseudocode on doubly-linked-lists

#### PushBack(key) on Doubly-linked-list

```pseudocode
node <- new node
node.key <- key; node.next = nil
if tail = nil:
    head <- tail <- node
    node.prev <- nil
else: 
    tail.next <- node 
    node.prev <- tail
    tail <- node
```

|  Doubly-Linked List  | no tail | with tail |
|:--------------------:|:-------:|:---------:|
|    PushFront(Key)    |   O(1)  |           |
|      TopFront()      |   O(1)  |           |
|      PopFront()      |   O(1)  |           |
|    PushBack(Key)     |   O(n)  |    O(1)   |
|      TopBack()       |   O(n)  |    O(1)   |
|      PopBack()       |   O(1)  |           |
|      Find(Key)       |   O(n)  |           |
|      Erase(Key)      |   O(n)  |           |
|       Empty()        |   O(1)  |           |
| AddBefore(Node, Key) |   O(1)  |           |
| AddAfter(Node, Key)  |   O(1)  |           |

### Summary Doubly-Linked Lists

- Constant time to insert at or remove from the front.
- With tail and doubly-linked, constant time to insert at or remove from the back.
- O(n) time to find arbitrary element.
- List elements need not to be contiguous.
- With doubly-linked list, constant time to insert between nodes or remove a node.
