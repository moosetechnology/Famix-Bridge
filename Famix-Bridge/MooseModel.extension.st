Extension { #name : 'MooseModel' }

{ #category : '*Famix-Bridge' }
MooseModel >> rootEntities [

	^ (ActiveMooseWorkspace value interModelModeActive and: [
		   ActiveMooseWorkspace value models includes: self ])
		  ifTrue: [ ActiveMooseWorkspace value rootEntities ]
		  ifFalse: [ super rootEntities ]
]
