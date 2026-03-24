Extension { #name : 'FamixTAssociation' }

{ #category : '*Moose-Workspace' }
FamixTAssociation >> equivalentSourceFoundIn: aCollection addingToMooseNames: newMooseNames [

	| res selfMooseName |
	selfMooseName := self source mooseName.
	res := aCollection anySatisfy: [ :sourceMooseName |
		       selfMooseName = sourceMooseName ].

	res ifFalse: [ newMooseNames add: selfMooseName ].
	^ res
]

{ #category : '*Moose-Workspace' }
FamixTAssociation >> equivalentTargetFoundIn: aCollection addingToMooseNames: newMooseNames [

	| res selfMooseName |
	selfMooseName := self target mooseName.
	res := aCollection anySatisfy: [ :sourceMooseName |
		       selfMooseName = sourceMooseName ].

	res ifFalse: [ newMooseNames add: selfMooseName ].
	^ res
]
