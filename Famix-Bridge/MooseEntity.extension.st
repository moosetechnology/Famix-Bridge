Extension { #name : 'MooseEntity' }

{ #category : '*Famix-Bridge' }
MooseEntity >> findAllVersionsOfEntity [

	| definedEntity allVersions |
	definedEntity := self isStub
		                 ifTrue: [ self resolveStub ]
		                 ifFalse: [ self ].

	allVersions := OrderedCollection new.
	allVersions add: definedEntity.
	allVersions addAll: definedEntity findStubsOfEntity.

	^ allVersions
]

{ #category : '*Famix-Bridge' }
MooseEntity >> findStubsOfEntity [
	
	^ FamixBridgeTool instance findStubsOf: self
]

{ #category : '*Famix-Bridge' }
MooseEntity >> getAllVersionsOfEntity [

	^ FamixBridgeTool instance getAllVersionsOfEntity: self
]

{ #category : '*Famix-Bridge' }
MooseEntity >> getResolvedStub [

	^ FamixBridgeTool instance getResource: self
]

{ #category : '*Famix-Bridge' }
MooseEntity >> resolveStub [

	self isStub ifFalse: [ ^ self ].
	^ FamixBridgeTool instance findResource: self
]
