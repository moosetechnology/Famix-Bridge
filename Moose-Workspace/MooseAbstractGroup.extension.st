Extension { #name : 'MooseAbstractGroup' }

{ #category : '*Moose-Workspace' }
MooseAbstractGroup >> entities [

	| workspace |
	workspace := ActiveMooseWorkspace value.
	^ (workspace interModelModeActive and: [
		   workspace models includes: self ])
		  ifTrue: [
				  | group models size |
				  models := workspace models asOrderedCollection sorted: [ :a :b |
					            a size > b size ].
				  "additional 1000 just in case?"
				  size := 1000.
				  workspace models do: [ :m | size := size + m size ].
				  group := OrderedCollection new: size.
				  models do: [ :m | group addAll: m entityStorage elements ].
				  FamixBridgeTool instance removeDuplicatesEntitiesOf: group.
				  group ]
		  ifFalse: [ self entityStorage elements ]
]
