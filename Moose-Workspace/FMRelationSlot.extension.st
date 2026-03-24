Extension { #name : 'FMRelationSlot' }

{ #category : '*Moose-Workspace' }
FMRelationSlot >> checkForNoResult: readReturnValue [
"returns true if read: anObject call return value is nil or empty, false otherwise"
	self subclassResponsibility 
]

{ #category : '*Moose-Workspace' }
FMRelationSlot >> readAndMergeResults: receiverEntities [

	| results mooseNames receiverMooseName isAssoc isSource readResults |
	results := OrderedCollection new. "FMSlotMultivalueLink is a subclass of OrderedCollection, so it should be fine to use it here? Maybe not ideal though"
	mooseNames := OrderedCollection new.
	
	receiverMooseName := receiverEntities anyOne bridgeMooseName.
	isAssoc := self targetClass usesTrait: FamixTAssociation.
	isSource := false.

	receiverEntities do: [ :r |
			| entityRes newMooseNames |
			"using a collection here to allow duplicates if they come from the same view of an entity"
			entityRes := OrderedCollection new.
			readResults := super read: r.
			isAssoc and: [
				readResults ifNotEmpty: [
					isSource := readResults anyOne source bridgeMooseName = receiverMooseName ] ].
			newMooseNames := OrderedCollection new.
			readResults do: [ :res |
					isAssoc
						ifTrue: [
								isSource
									ifTrue: [
											(res
												 equivalentTargetFoundIn: mooseNames
												 addingToMooseNames: newMooseNames) ifFalse: [
												entityRes add: res ] ]
									ifFalse: [
											(res
												 equivalentSourceFoundIn: mooseNames
												 addingToMooseNames: newMooseNames) ifFalse: [
												entityRes add: res ] ] ]
						ifFalse: [
								(res
									 equivalentFoundIn: mooseNames
									 addingToMooseNames: newMooseNames) ifFalse: [
									entityRes add: res ] ] ].
			mooseNames addAll: newMooseNames.
			results addAll: entityRes ].

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

	self subclassResponsibility 
]

{ #category : '*Moose-Workspace' }
FMRelationSlot >> resolveResult: val [

	self subclassResponsibility 
]
