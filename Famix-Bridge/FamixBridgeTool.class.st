"
I am a tool helping to build queries that are navigating from one model to another through stubs.
This class uses a singleton design pattern.

API : 
- findResource: stub >> Returns, if found, a defined entity matching the given stub
- findStubsOf: resource >> Returns, if found, a list of stubs representing the given defined entity
"
Class {
	#name : 'FamixBridgeTool',
	#superclass : 'Object',
	#instVars : [
		'sourceModel',
		'cache'
	],
	#classInstVars : [
		'instance'
	],
	#category : 'Famix-Bridge',
	#package : 'Famix-Bridge'
}

{ #category : 'accessing' }
FamixBridgeTool class >> instance [

	instance ifNil: [ instance := super new ].
	^ instance
]

{ #category : 'instance creation' }
FamixBridgeTool class >> new [
	self error: 'Singleton class. Use the message #instance to get the bridge tool.'
]

{ #category : 'initialization' }
FamixBridgeTool class >> onModel: sourceModel [

	^ self instance
		  sourceModel: sourceModel;
		  yourself
]

{ #category : 'selecting models' }
FamixBridgeTool >> allModelsButSourceModel [

	^ MooseModel root entities reject: [ :m | m = sourceModel ]
]

{ #category : 'selecting models' }
FamixBridgeTool >> allWorkspaceModelsButSourceModel [

	| workspace |
	"this method is only called when there is an active workspace, so no checks are done"
	workspace := ActiveMooseWorkspace value.

	^ workspace models reject: [ :m | m = sourceModel ]
]

{ #category : 'cache management' }
FamixBridgeTool >> clearCache [ 

	cache clearCache 
]

{ #category : 'cache management' }
FamixBridgeTool >> disableCache [ 

	cache disable
]

{ #category : 'cache management' }
FamixBridgeTool >> enableCache [ 

	cache enable
]

{ #category : 'searching stubs' }
FamixBridgeTool >> find: stubEntity amongChildrenOf: currentSearchResult [
	"The code could be simple but we have optimizations:
	- We save the name because we need to access it a lot
	- We use a #do: instead of a detect: to not have to build the full contained entities list in case we find the right result in the first entities"

	| name |
	name := stubEntity name.
	currentSearchResult containedEntitiesDo: [ :child | (child class = stubEntity class and: [ child name = name ]) ifTrue: [ ^ child ] ].

	^ nil
]

{ #category : 'searching resources' }
FamixBridgeTool >> findResource: stub [

	sourceModel := stub mooseModel.
	^ self findResourceWithinWorkspace: stub
]

{ #category : 'searching resources' }
FamixBridgeTool >> findResource: stub inModel: resourceModel [

	^ (cache definedEntity: stub inModel: resourceModel)
		  ifNotNil: [ :entity | entity ]
		  ifNil: [ self searchResource: stub inModel: resourceModel ]
]

{ #category : 'searching resources' }
FamixBridgeTool >> findResource: stub withinModels: modelsToSearch [

	modelsToSearch do: [ :m |
			| searchResult |
			searchResult := self findResource: stub inModel: m.
			searchResult ifNotNil: [ ^ searchResult ] ].

	"by default, return the stub if no defined version found"
	^ stub
]

{ #category : 'searching resources' }
FamixBridgeTool >> findResourceLookingThroughAllModels: stub [
	"TODO : consider the possibility of results in several models and modify as needed"

	^ self findResource: stub withinModels: self allModelsButSourceModel
]

{ #category : 'searching resources' }
FamixBridgeTool >> findResourceWithinWorkspace: stub [
		
	^ self findResource: stub withinModels: self allWorkspaceModelsButSourceModel
]

{ #category : 'searching stubs' }
FamixBridgeTool >> findStub: entity inModel: resourceModel [

	^ (cache stubEntity: entity inModel: resourceModel)
		  ifNotNil: [ :stub | stub ]
		  ifNil: [ self searchStub: entity inModel: resourceModel ]
]

{ #category : 'searching stubs' }
FamixBridgeTool >> findStubs: stub withinModels: modelsToSearch [

	| stubList |
	stubList := OrderedCollection new.
	
	modelsToSearch do: [ :m |
		| searchResult |
		searchResult := self findStub: stub inModel: m.
		searchResult ifNotNil: [ stubList add: searchResult ] ].

	^ stubList 
]

{ #category : 'searching stubs' }
FamixBridgeTool >> findStubsLookingThroughAllModels: entity [
	"TODO : consider the possibility of results in several models and modify as needed"

	^ self findStubs: entity withinModels: self allModelsButSourceModel
]

{ #category : 'searching stubs' }
FamixBridgeTool >> findStubsOf: entity [
	"TODO : consider the possibility of results in several models and modify as needed"
	sourceModel := entity mooseModel.

	^ ActiveMooseWorkspace value interModelModeActive 
		  ifTrue: [ self findStubsWithinWorkspace: entity ]
		  ifFalse: [ self findStubsLookingThroughAllModels: entity ]
]

{ #category : 'searching stubs' }
FamixBridgeTool >> findStubsWithinWorkspace: entity [
		
	^ self findStubs: entity withinModels: self allWorkspaceModelsButSourceModel
]

{ #category : 'initialization' }
FamixBridgeTool >> initialize [ 

	cache := BridgeCache new
]

{ #category : 'cache management' }
FamixBridgeTool >> isCacheEnabled [

	^ cache enabled
]

{ #category : 'searching' }
FamixBridgeTool >> searchEntity: entity inModel: resourceModel [

	| parentsList currentSearchResult |
	parentsList := entity allContainers reverse.
	currentSearchResult := resourceModel rootEntities
		                       detect: [ :e |
		                       e name = parentsList first name ]
		                       ifNone: [ ^ nil ].
			
	parentsList allButFirst do: [ :p |
			currentSearchResult := self
				                       find: p
				                       amongChildrenOf: currentSearchResult.
			currentSearchResult ifNil: [ ^ nil ] ].
		
	^ currentSearchResult := self
		                         find: entity
		                         amongChildrenOf: currentSearchResult
]

{ #category : 'searching resources' }
FamixBridgeTool >> searchResource: stub inModel: resourceModel [

	| searchResult |
	ActiveMooseWorkspace value interModelModeActive: false.
	searchResult := self searchEntity: stub inModel: resourceModel.
	ActiveMooseWorkspace value interModelModeActive: true.

	^ searchResult ifNotNil: [
			  searchResult isStub not
				  ifTrue: [
						  cache addDefinedEntity: searchResult.
						  searchResult ]
				  ifFalse: [ nil ] ]
]

{ #category : 'searching stubs' }
FamixBridgeTool >> searchStub: entity inModel: resourceModel [

	| searchResult |
	ActiveMooseWorkspace value interModelModeActive: false.
	searchResult := self searchEntity: entity inModel: resourceModel.
	ActiveMooseWorkspace value interModelModeActive: true.

	^ searchResult ifNotNil: [
			  searchResult isStub
				  ifTrue: [
						  cache addStubEntity: searchResult.
						  searchResult ]
				  ifFalse: [ nil ] ]
]

{ #category : 'accessing' }
FamixBridgeTool >> sourceModel [

	^ sourceModel
]

{ #category : 'accessing' }
FamixBridgeTool >> sourceModel: anObject [

	sourceModel := anObject
]
