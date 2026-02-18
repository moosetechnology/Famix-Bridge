"
I am representing a set of Moose models forming a full software configuration, including a main project and the libraries it depends on.

I can run inter model queries using the method `interModelModeDuring:aBlock`. This method sets my instance as value of the `DynamicVariable` named `ActiveMooseWorkspace`, which ensures that the queries in the block given as parameter will be able to navigate through different models if necessary. 
I can use different resolution strategies during my inter model mode, which I store in the instance variable `stubResolverStrategy`. It must have as a value a subclass of `AbstractStubResolverStrategy`.

API:

- `addLibraryModel: aMooseModel`
- `removeLibraryModel: aMooseModel`
- `mainModel: aMooseModel`
- `stubResolverStrategy: anObject`
- `interModelModeDuring: aBlock`
"
Class {
	#name : 'MooseWorkspace',
	#superclass : 'MooseObject',
	#traits : 'MooseTWorkspace',
	#classTraits : 'MooseTWorkspace classTrait',
	#instVars : [
		'models',
		'stubResolverStrategy'
	],
	#category : 'Moose-Workspace-Core',
	#package : 'Moose-Workspace',
	#tag : 'Core'
}

{ #category : 'adding - removing' }
MooseWorkspace >> addLibraryModel: aMooseModel [

	models add: aMooseModel 
]

{ #category : 'adding - removing' }
MooseWorkspace >> clearLibrairiesModel [
	| mainModel |
	mainModel := self mainModel.
	models := Set new.
	mainModel ifNotNil: [ models add: mainModel ]
]

{ #category : 'as yet unclassified' }
MooseWorkspace >> createFullMMECache [
	
	"making sure the cache is enabled"
	FamixBridgeTool instance enableCache.

	self interModelModeDuring: [
		FamixBridgeTool instance fullMMECacheFor: self ]
]

{ #category : 'initialization' }
MooseWorkspace >> defaultStubResolverStrategy [

	^ ResolveAndMergeResultsStrategy new
]

{ #category : 'initialization' }
MooseWorkspace >> initialize [ 
	super initialize.
	
	stubResolverStrategy := self defaultStubResolverStrategy.
	models := Set new.
]

{ #category : 'inter-model protocol' }
MooseWorkspace >> interModelModeDuring: aBlock [
	"sets self as the dynamic variable value, and activates inter model mode for the execution of the block"
	interModelModeActive := true.
	^ ActiveMooseWorkspace
		value: self
		during: [ aBlock value ]
]

{ #category : 'accessing' }
MooseWorkspace >> librariesModels [

	| mainModel |
	mainModel := self mainModel.
	^ models reject: [ :m | m = mainModel ]
]

{ #category : 'accessing' }
MooseWorkspace >> mainModel [
	
	^ self attributeAt: #mainModel ifAbsent: [ nil ]
]

{ #category : 'accessing' }
MooseWorkspace >> mainModel: anObject [

	(models includes: anObject) ifFalse: [ models add: anObject ].

	self
		attributeAt: #mainModel
		ifAbsent: [ ^ self simpleSetMainModel: anObject ].
	"if present"
	self removePreviousMainModelAndSetMainModel: anObject
]

{ #category : 'accessing' }
MooseWorkspace >> models [

	^ models
]

{ #category : 'accessing' }
MooseWorkspace >> models: anObject [

	models := anObject
]

{ #category : 'adding - removing' }
MooseWorkspace >> removeLibraryModel: aMooseModel [

	models remove: aMooseModel 
]

{ #category : 'accessing' }
MooseWorkspace >> removePreviousMainModelAndSetMainModel: anObject [

	models remove: self mainModel.
	self simpleSetMainModel: anObject
]

{ #category : 'accessing' }
MooseWorkspace >> simpleSetMainModel: anObject [

	self attributeAt: #mainModel put: anObject
]

{ #category : 'meta-object-protocol' }
MooseWorkspace >> slot: aFMRelationSlot read: anObject [

	^ stubResolverStrategy slot: aFMRelationSlot read: anObject 
]

{ #category : 'accessing' }
MooseWorkspace >> stubResolverStrategy [

	^ stubResolverStrategy
]

{ #category : 'accessing' }
MooseWorkspace >> stubResolverStrategy: anObject [

	stubResolverStrategy := anObject
]
