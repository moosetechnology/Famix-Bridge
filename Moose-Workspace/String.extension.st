Extension { #name : 'String' }

{ #category : '*Moose-Workspace' }
String >> equivalentFoundIn: aCollection [

	^ aCollection anySatisfy: [ :entity |
		  entity mooseName = self ]
]

{ #category : '*Moose-Workspace' }
String >> equivalentSourceFoundIn: aCollection [ 
	^ aCollection anySatisfy: [ :assoc | assoc source mooseName = self ]
]

{ #category : '*Moose-Workspace' }
String >> equivalentTargetFoundIn: aCollection [ 
	^ aCollection anySatisfy: [ :assoc | assoc target mooseName = self ]
]
