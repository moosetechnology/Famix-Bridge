Extension { #name : 'FMMany' }

{ #category : '*Moose-Workspace' }
FMMany >> checkForNoResult: readReturnValue [
"returns true if read: anObject call return value is nil or empty, false otherwise"
	^ readReturnValue isEmpty
]

{ #category : '*Moose-Workspace' }
FMMany >> getVersionsOfEntity: anObject [
	
	^ anObject getAllVersionsOfEntity 
]

{ #category : '*Moose-Workspace' }
FMMany >> read: anObject [

	| workspace |
	"If I can be a stub or if I am an association, I need resolving"
	(anObject canBeStub or: [ anObject isAssociation ]) ifFalse: [
		^ super read: anObject ].

	workspace := ActiveMooseWorkspace value.
	^ (workspace interModelModeActive and: [
		   workspace models includes: anObject mooseModel ])
		  ifTrue: [ self readResolveAndMergeResults: anObject ]
		  ifFalse: [ super read: anObject ]
]

{ #category : '*Moose-Workspace' }
FMMany >> readResolveAndMergeResults: anObject [
"For a FMMany slot, return the composition of the results of reading this slot for every version of the entity"
	| receiverEntities |
	receiverEntities := self getVersionsOfEntity: anObject.

	^ receiverEntities isCollection
		  ifTrue: [ self readAndMergeResults: receiverEntities ]
		  ifFalse: [ self readAndResolveIfStubResult: receiverEntities ]
]

{ #category : '*Moose-Workspace' }
FMMany >> resolveResult: aCollection [
	"returns the resolved entity if it is found, returns the stub entity otherwise"

	aCollection ifEmpty: [ ^ aCollection ].

	^ aCollection collect: [ :stub |
		  | resolvedEntity |
		  resolvedEntity := stub getResolvedStub.
		  resolvedEntity
			  ifNotNil: [
			  resolvedEntity "stub was resolved, store resolved entity" ]
			  ifNil: [ stub "stub was not resolved, store stub entity" ] ]
]
