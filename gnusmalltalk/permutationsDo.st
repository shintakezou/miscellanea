"helper for permutationsDo"
Array extend [
   addAt: aIndex value: aValue [
      "calls binary + between the element at index aIndex 
       and aValue, and updates the element at index aIndex
       with the result."
      <category: 'manipulation'>

      self at: aIndex put: (self at: aIndex) + aValue.
      ^self.
   ]
].

"My GNU Smalltalk 3.2.4 does not implement permutationsDo,
 even though indeed gst's REPL autocomplete it when I hit <TAB>.
 This is a non-recursive implementation of the Heap's algorithm as
 described in Wikipedia. Hopefully correct, and likely it should
 be implemented into SequenceableCollection instead of into
 OrderedCollection."
OrderedCollection extend [
    permutationsDo: aBlock [
       "executes block aBlock for each permutation of the
        OrderedCollection."
       <category: 'enumerating'>
       
       |c m i|
       m := self copy.
       c := (1 to: (self size)) collect: [:i| 0 ].
       aBlock value: m.
       i := 0.
       [ i < (self size) ] whileTrue: [
           (c at: (i+1)) < i
           ifTrue: [
               i even
               ifTrue: [
                   m swap: 1 with: (i+1) ]
               ifFalse: [
                   m swap: (c at: (i+1))+1 with: i+1
               ].
               aBlock value: m.
               c addAt: (i+1) value: 1.
               i := 0.
           ]
           ifFalse: [
               c at: (i+1) put: 0.
               i := i + 1.
           ].
       ]
    ]
].
