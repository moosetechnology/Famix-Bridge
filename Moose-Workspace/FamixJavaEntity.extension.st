Extension { #name : 'FamixJavaEntity' }

{ #category : '*Moose-Workspace' }
FamixJavaEntity >> equivalentFoundIn: aCollection [

	^ aCollection anySatisfy: [ :entity |
		  entity mooseName = self mooseName ]
]
