"
I am a cache for the `FamixBridgeTool` instance.

Every time the bridge tool receives a search request, I am called to either :
- Create a new entry if the entity searched has never been searched before, in any model
- Edit an existing entry if the entity searched has been searched before, but in another model
- Consult an entry if the entity searched has been searched before, for the model targeted by the search request

Each entry in my hash table uses a moose name as key, and an instance of `MultiModelEntity` as value.

I can be disabled or enabled using the `enable` and `disable` message, but this should only be used for testing or benchmarking purposes.
"
Class {
	#name : 'BridgeCache',
	#superclass : 'Object',
	#instVars : [
		'cacheHashTable',
		'enabled'
	],
	#category : 'Famix-Bridge',
	#package : 'Famix-Bridge'
}

{ #category : 'testing' }
BridgeCache >> addDefinedEntity: anEntity [

	| value |
	enabled ifFalse: [ ^ self ].

	value := cacheHashTable
		         at: anEntity mooseName
		         ifAbsentPut: [ MultiModelEntity new ].

	value addDefinedEntity: anEntity
]

{ #category : 'testing' }
BridgeCache >> addStubEntities: stubList [

	| value |
	enabled ifFalse: [ ^ self ].
	
	value := cacheHashTable
		         at: stubList anyOne mooseName
		         ifAbsentPut: [ MultiModelEntity new ].
	
	stubList do: [ :stub | value addStubEntity: stub ]
	
]

{ #category : 'testing' }
BridgeCache >> addStubEntity: aStub [

	| value |
	enabled ifFalse: [ ^ self ].
	
	value := cacheHashTable
		         at: aStub mooseName
		         ifAbsentPut: [ MultiModelEntity new ].

	value addStubEntity: aStub
]

{ #category : 'accessing cache' }
BridgeCache >> allVersionsOf: entity [ 
	"returns the defined entity of the given stub found in any model. returns nil if value isn't in cache"

	enabled ifFalse: [ ^ nil ].

	"should be only one, but cache structure needs to change anyway so it'll be changed"
	^ cacheHashTable at: entity mooseName ifPresent: [ :mme |
		  mme allVersions ]
]

{ #category : 'as yet unclassified' }
BridgeCache >> clearCache [

	cacheHashTable := HashTable new
]

{ #category : 'as yet unclassified' }
BridgeCache >> createEntryForEntities: aCollection [ 
	| key |
	key := aCollection anyOne mooseName.
	cacheHashTable at: key ifAbsentPut: [ MultiModelEntity forEntities: aCollection ]
]

{ #category : 'accessing cache' }
BridgeCache >> definedEntity: aStub [
	"returns the defined entity of the given stub found in any model. returns nil if value isn't in cache"

	enabled ifFalse: [ ^ nil ].

	"should be only one, but cache structure needs to change anyway so it'll be changed"
	^ cacheHashTable at: aStub mooseName ifPresent: [ :mme |
			  mme definedEntities
				  ifEmpty: [ nil ]
				  ifNotEmpty: [ mme definedEntities anyOne ] ]
]

{ #category : 'accessing cache' }
BridgeCache >> definedEntity: aStub inModel: aMooseModel [
	"returns the defined entity of the given stub found in the given model. returns nil if value isn't in cache"

	enabled ifFalse: [ ^ nil ].

	^ cacheHashTable at: aStub mooseName ifPresent: [ :mme |
		  mme definedEntities
			  at: aMooseModel mooseID
			  ifPresent: [ :entity | entity ] ]
]

{ #category : 'accessing cache' }
BridgeCache >> definedEntityExists: aStub [
	"returns true if a defined entity exists for this stub"

	| res |
	enabled ifFalse: [ ^ nil ].

	res := cacheHashTable
		       at: aStub mooseName
		       ifPresent: [ :mme | mme definedEntities isNotEmpty ].

	^ res ifNil: [ false ] ifNotNil: [ res ]
]

{ #category : 'accessing' }
BridgeCache >> disable [ 

	enabled := false
]

{ #category : 'accessing' }
BridgeCache >> enable [ 

	enabled := true
]

{ #category : 'accessing' }
BridgeCache >> enabled [

	^ enabled
]

{ #category : 'as yet unclassified' }
BridgeCache >> getDuplicatesFrom: aMooseWorkspace [

	^ cacheHashTable flatCollect: [ :value | value stubEntities values ]
]

{ #category : 'initialization' }
BridgeCache >> initialize [ 
	
	cacheHashTable := HashTable new.
	enabled := true
]

{ #category : 'testing' }
BridgeCache >> isIn: mooseName [

	| isIn |
	isIn := false.
	cacheHashTable at: mooseName ifPresent: [ :e | isIn := true ].
	^ isIn
]

{ #category : 'as yet unclassified' }
BridgeCache >> stubEntity: anEntity inModel: aMooseModel [
	"returns the stub of the given entity found in the given model. returns nil if value isn't in cache"

	enabled ifFalse: [ ^ nil ].

	^ cacheHashTable at: anEntity mooseName ifPresent: [ :mme |
		  mme stubEntities
			  at: aMooseModel mooseID
			  ifPresent: [ :stub | stub ] ]
]
