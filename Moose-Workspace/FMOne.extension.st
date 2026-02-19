Extension { #name : 'FMOne' }

{ #category : '*Moose-Workspace' }
FMOne >> checkForNoResult: readReturnValue [
"returns true if read: anObject call return value is nil or empty, false otherwise"
	^ readReturnValue isNil
]

{ #category : '*Moose-Workspace' }
FMOne >> findVersionsOfEntity: anObject [

	"^ anObject" 

	"calling this method with the code here after triggers an infinite loop (due to calling mooseNameOn: for caching purposes, which calls the parent entity)"

	anObject isStub ifFalse: [ ^ anObject ].
	
	^ anObject resolveStub ifNil: [ anObject ]
]

{ #category : '*Moose-Workspace' }
FMOne >> read: anObject [

	anObject canBeStub ifFalse: [ ^ super read: anObject ].

	^ ActiveMooseWorkspace value interModelModeActive
		  ifTrue: [ self readResolveAndMergeResults: anObject ]
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

	resolvedEntity := anObject resolveStub.
	^ resolvedEntity 
		ifNotNil: [ resolvedEntity ] "stub was resolved, return resolved entity"
		ifNil: [ anObject ] "stub was not resolved, return stub entity"
]
