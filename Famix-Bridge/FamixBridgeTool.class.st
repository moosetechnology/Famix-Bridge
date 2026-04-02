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
		'currentWorkspace',
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
FamixBridgeTool >> allWorkspaceModelsButSourceModel [

	^ currentWorkspace models reject: [ :m | m = sourceModel ]
]

{ #category : 'as yet unclassified' }
FamixBridgeTool >> cacheModelPackagesFor: aMooseWorkspace [
	"packages can also be shared, with multiple defined versions"

	aMooseWorkspace models do: [ :m |
			m allModelPackages do: [ :p |
					| allVersions grouped |
					allVersions := p
						               findAllVersionsOfEntityWithMultipleDefinedEntities.
					grouped := allVersions groupedBy: [ :e | e mooseModel mooseID ].
					(allVersions size > 1 and: [ grouped size > 1 ]) ifTrue: [
						aMooseWorkspace mmeCache createEntryForEntities: allVersions ] ] ]
]

{ #category : 'cache management' }
FamixBridgeTool >> clearCache [ 

	cache clearCache 
]

{ #category : 'private - accessing' }
FamixBridgeTool >> currentWorkspace: anObject [
	"used for testing purposes"

	currentWorkspace := anObject
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
	name := stubEntity mooseName.
	currentSearchResult containedEntitiesDo: [ :child | (child class = stubEntity class and: [ child mooseName = name ]) ifTrue: [ ^ child ] ].

	^ nil
]

{ #category : 'searching resources' }
FamixBridgeTool >> findResource: stub [

	sourceModel := stub mooseModel.
	currentWorkspace := ActiveMooseWorkspace value.
	^ self
		  findResource: stub
		  withinModels: self allWorkspaceModelsButSourceModel
]

{ #category : 'searching resources' }
FamixBridgeTool >> findResource: stub inModel: resourceModel [

	^ (currentWorkspace mmeCache
		   definedEntity: stub
		   inModel: resourceModel)
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

{ #category : 'searching stubs' }
FamixBridgeTool >> findStub: entity inModel: resourceModel [

	^ (currentWorkspace mmeCache
		   stubEntity: entity
		   inModel: resourceModel)
		  ifNotNil: [ :stub | stub ]
		  ifNil: [ self searchStub: entity inModel: resourceModel ]
]

{ #category : 'searching stubs' }
FamixBridgeTool >> findStubs: entity withinModels: modelsToSearch [

	| stubList |
	stubList := OrderedCollection new.
	entity isStub ifTrue: [ stubList add: entity ].

	modelsToSearch do: [ :m |
			| searchResult |
			searchResult := self findStub: entity inModel: m.
			searchResult ifNotNil: [ stubList add: searchResult ] ].

	stubList isEmpty ifTrue: [ ^ stubList ].

	(stubList size > 1 or: [
		 currentWorkspace mmeCache definedEntityExists: stubList anyOne ])
		ifTrue: [ "cache addStubEntities: stubList" ].

	^ stubList
]

{ #category : 'searching stubs' }
FamixBridgeTool >> findStubsOf: entity [

	sourceModel := entity mooseModel.
	currentWorkspace := ActiveMooseWorkspace value.
	^ self
		  findStubs: entity
		  withinModels: self allWorkspaceModelsButSourceModel
]

{ #category : 'as yet unclassified' }
FamixBridgeTool >> fullMMECacheFor: aMooseWorkspace [

	| classesToReject |
	classesToReject := { FamixJavaImplicitVariable }.

	aMooseWorkspace models do: [ :m |
			| stubs |
			aMooseWorkspace interModelModeActive: false.
			stubs := (m entities reject: [ :e |
				          classesToReject includes: e class ]) select: [ :e |
				         e isStub ].
			aMooseWorkspace interModelModeActive: true.
			stubs do: [ :s |
					| allVersions grouped |
					allVersions := s findAllVersionsOfEntity.
					grouped := allVersions groupedBy: [ :e | e mooseModel mooseID ].
					(allVersions size > 1 and: [ grouped size > 1 ]) ifTrue: [
						currentWorkspace mmeCache createEntryForEntities: allVersions ] ] ]
]

{ #category : 'as yet unclassified' }
FamixBridgeTool >> getAllVersionsOfEntity: entity [

	^ (currentWorkspace mmeCache allVersionsOf: entity)
		  ifNotNil: [ :entities | entities ]
		  ifNil: [ entity ]
]

{ #category : 'as yet unclassified' }
FamixBridgeTool >> getResource: stub [

	^ (currentWorkspace mmeCache definedEntity: stub)
		  ifNotNil: [ :entity | entity ]
		  ifNil: [ nil ]
]

{ #category : 'initialization' }
FamixBridgeTool >> initialize [ 

	cache := BridgeCache new
]

{ #category : 'cache management' }
FamixBridgeTool >> isCacheEnabled [

	^ cache enabled
]

{ #category : 'removing' }
FamixBridgeTool >> removeDuplicatesEntitiesOf: anOrderedCollection [

	| duplicates |
	duplicates := currentWorkspace mmeCache getDuplicatesFrom: ActiveMooseWorkspace value.
	anOrderedCollection removeAllSuchThat: [ :e |
		(currentWorkspace mmeCache isIn: e mooseName) and: [ duplicates includes: e ] ]
]

{ #category : 'searching' }
FamixBridgeTool >> searchEntity: entity inModel: resourceModel [

	| parentsList currentSearchResult |
	ActiveMooseWorkspace value interModelModeActive: false.
	
	parentsList := entity allContainers.
	parentsList	addFirst: entity.
	parentsList := parentsList reverse.
		
	currentSearchResult := resourceModel rootEntities
		                       detect: [ :e |
		                       e mooseName = parentsList first mooseName ]
		                       ifNone: [ ^ nil ].

	parentsList allButFirst do: [ :p |
			currentSearchResult := self
				                       find: p
				                       amongChildrenOf: currentSearchResult.
			currentSearchResult ifNil: [ ^ nil ] ].
		
	ActiveMooseWorkspace value interModelModeActive: true.

	^ currentSearchResult
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
						  "cache addDefinedEntity: searchResult."
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
						  "cache addStubEntity: searchResult."
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
