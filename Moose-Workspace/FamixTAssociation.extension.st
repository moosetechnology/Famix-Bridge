Extension { #name : 'FamixTAssociation' }

{ #category : '*Moose-Workspace' }
FamixTAssociation >> equivalentSourceFoundIn: aCollection [ 
	^ aCollection anySatisfy: [ :assoc | assoc source mooseName = self source mooseName ]
]

{ #category : '*Moose-Workspace' }
FamixTAssociation >> equivalentTargetFoundIn: aCollection [ 
	^ aCollection anySatisfy: [ :assoc | assoc target mooseName = self target mooseName ]
]
