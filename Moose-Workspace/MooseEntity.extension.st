Extension { #name : 'MooseEntity' }

{ #category : '*Moose-Workspace' }
MooseEntity >> equivalentFoundIn: aCollection addingToMooseNames: newMooseNames [

	| res selfMooseName |
	selfMooseName := self mooseName.
	res := aCollection anySatisfy: [ :entityMooseName |
		       selfMooseName = entityMooseName ].

	res ifFalse: [ newMooseNames add: selfMooseName ].
	^ res
]
