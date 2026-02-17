Extension { #name : 'FMRelationSlot' }

{ #category : '*Moose-Workspace' }
FMRelationSlot >> checkForNoResult: readReturnValue [
"returns true if read: anObject call return value is nil or empty, false otherwise"
	self subclassResponsibility 
]

{ #category : '*Moose-Workspace' }
FMRelationSlot >> findVersionsOfEntity: anObject [

	self subclassResponsibility
]

{ #category : '*Moose-Workspace' }
FMRelationSlot >> read: anObject [

	anObject canBeStub ifFalse: [ ^ super read: anObject ].

	^ ActiveMooseWorkspace value interModelModeActive
		  ifTrue: [ ActiveMooseWorkspace value slot: self read: anObject ]
		  ifFalse: [ super read: anObject ]
]

{ #category : '*Moose-Workspace' }
FMRelationSlot >> readAndMergeResults: receiverEntities [

	| results | 
	results := OrderedCollection new. "FMSlotMultivalueLink is a subclass of OrderedCollection, so it should be fine to use it here? Not ideal though"
	receiverEntities do: [ :r | results addAll: (super read: r) ].
	
	^ results
]

{ #category : '*Moose-Workspace' }
FMRelationSlot >> readAndResolveIfCalledForStub: anObject [

	| realEntity |
	"usual behaviour, entity calling read method is not a stub"
	anObject isStub ifFalse: [ ^ super read: anObject ].

	"inter-model protocol"
	realEntity := anObject resolveStub.

	^ realEntity
		  ifNil: [ "stub could not be resolved, resuming usual behaviour"
			  super read: anObject ]
		  ifNotNil: [ "stub could be resolved, reading slot on real entity"
			  super read: realEntity ]
]

{ #category : '*Moose-Workspace' }
FMRelationSlot >> readAndResolveIfStubResult: anObject [

	| val |
	val := super read: anObject.
	
	^ self resolveResult: val
]

{ #category : '*Moose-Workspace' }
FMRelationSlot >> readAndResolveOnNoResult: anObject [

	| val |
	val := super read: anObject.
	
	"inter-model protocol code"
	((self checkForNoResult: val) and: [ anObject isStub ]) ifTrue: [
		| realEntity |
		realEntity := anObject resolveStub.
		realEntity ifNotNil: [ ^ super read: realEntity ] ].
	
	"usual expected behaviour (if there is no need for inter-model protocol or if stub can't be resolved)"
	^ val
]

{ #category : '*Moose-Workspace' }
FMRelationSlot >> readResolveAndMergeResults: anObject [

	| receiverEntities |
	receiverEntities := self findVersionsOfEntity: anObject.

	^ receiverEntities isCollection
		  ifTrue: [ self readAndMergeResults: receiverEntities ]
		  ifFalse: [ self resolveResult: (super read: receiverEntities) ]
]

{ #category : '*Moose-Workspace' }
FMRelationSlot >> resolveResult: val [

	self subclassResponsibility 
]
