Extension { #name : 'MooseAbstractGroup' }

{ #category : '*Moose-Workspace' }
MooseAbstractGroup >> entities [

	| workspace |
	workspace := ActiveMooseWorkspace value.
	^ (workspace interModelModeActive and: [
		   workspace models includes: self ])
		  ifTrue: [
				  | group models |
				  models := workspace models asOrderedCollection.
				  group := MooseGroup withAll: models first entityStorage elements.
				  models allButFirstDo: [ :m |
					  group addAll: m entityStorage elements ].
				  FamixBridgeTool instance removeDuplicatesEntitiesOf: group.
				  group ]
		  ifFalse: [ self entityStorage elements ]
]
