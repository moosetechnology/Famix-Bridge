Extension { #name : 'MooseEntity' }

{ #category : '*Moose-Workspace' }
MooseEntity >> bridgeMooseName [

	| mooseName |
	ActiveMooseWorkspace value interModelModeActive: false.
	mooseName := self mooseName.
	ActiveMooseWorkspace value interModelModeActive: true.
	^ mooseName
]

{ #category : '*Moose-Workspace' }
MooseEntity >> equivalentFoundIn: aCollection addingToMooseNames: newMooseNames [

	| res selfMooseName |
	selfMooseName := self mooseName.
	res := aCollection anySatisfy: [ :entityMooseName |
		       selfMooseName = entityMooseName ].

	res ifFalse: [ newMooseNames add: selfMooseName ].
	^ res
]
