Extension { #name : 'FMOne' }

{ #category : '*Moose-Workspace' }
FMOne >> checkForNoResult: readReturnValue [
"returns true if read: anObject call return value is nil or empty, false otherwise"
	^ readReturnValue isNil
]

{ #category : '*Moose-Workspace' }
FMOne >> read: anObject [

	| workspace |
	workspace := ActiveMooseWorkspace value.
	workspace interModelModeActive ifFalse: [ ^ super read: anObject ].
	
	"If I can be a stub or if I am an association, I need resolving"
	(anObject canBeStub or: [ anObject isAssociation ]) ifFalse: [
		^ super read: anObject ].

	^ (workspace models includes: anObject mooseModel)
		  ifTrue: [
				  workspace
					  at: anObject
					  at: self
					  ifAbsentPut: [ self readResolveAndMergeResults: anObject ] ]
		  ifFalse: [ super read: anObject ]
]

{ #category : '*Moose-Workspace' }
FMOne >> readResolveAndMergeResults: anObject [
"For a FMOne slot, return (if it exists) the defined entity"
	^ self resolveResult: (super read: anObject) 
]

{ #category : '*Moose-Workspace' }
FMOne >> resolveResult: anObject [
"returns the resolved entity if it is found, returns the stub entity otherwise"
	| resolvedEntity |
	anObject ifNil: [ ^ nil ].

	resolvedEntity := anObject getResolvedStub.
	^ resolvedEntity 
		ifNotNil: [ resolvedEntity ] "stub was resolved, return resolved entity"
		ifNil: [ anObject ] "stub was not resolved, return stub entity"
]
