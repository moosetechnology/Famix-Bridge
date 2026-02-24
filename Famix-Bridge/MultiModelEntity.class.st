"
I am a table entry for the BridgeCache representing several representations of a same entity.

I hold `definedEntities` and `stubEntities` in my instance variables, which are two Dictionaries where the keys are Moose models `mooseID` and the values are the entity found within the model used as a key.
There is no risk that two values use the same key, since the `mooseName` of an entity is unique within its model. 

I also keep track of the `searchedModels`, a `Set` of `mooseID` for every model which has been searched before, which allows the tool consulting me to know if a pertinent model hasn't been searched or if no additional search is necessary.
"
Class {
	#name : 'MultiModelEntity',
	#superclass : 'MooseObject',
	#instVars : [
		'searchedModels',
		'definedEntities',
		'stubEntities'
	],
	#category : 'Famix-Bridge',
	#package : 'Famix-Bridge'
}

{ #category : 'instance creation' }
MultiModelEntity class >> newForDeclaredEntity: anEntity [

	^ self new
		  addStubEntity: anEntity;
		  yourself
]

{ #category : 'instance creation' }
MultiModelEntity class >> newForStub: aStub [

	^ self new
		  addStubEntity: aStub;
		  yourself
]

{ #category : 'adding' }
MultiModelEntity >> addDefinedEntity: anEntity [

	definedEntities at: anEntity mooseModel mooseID put: anEntity.
	searchedModels add: anEntity mooseModel mooseID
]

{ #category : 'adding' }
MultiModelEntity >> addStubEntity: anEntity [

	stubEntities at: anEntity mooseModel mooseID put: anEntity.
	searchedModels add: anEntity mooseModel mooseID
]

{ #category : 'as yet unclassified' }
MultiModelEntity >> allVersions [ 

	| versions |
	versions := OrderedCollection new.
	versions addAll: definedEntities values.
	versions addAll: stubEntities values.
	^ versions
]

{ #category : 'accessing' }
MultiModelEntity >> definedEntities [

	^ definedEntities
]

{ #category : 'initialization' }
MultiModelEntity >> initialize [ 
	super initialize.
	
	searchedModels := Set new.
	definedEntities := Dictionary new.
	stubEntities := Dictionary new.
]

{ #category : 'printing' }
MultiModelEntity >> mooseNameOn: aStream [

	aStream
		nextPutAll: 'MME : ';
		nextPutAll: (definedEntities isEmpty
				 ifTrue: [ stubEntities values anyOne name ]
				 ifFalse: [ definedEntities values anyOne name ]);
		nextPutAll: ' (';
		nextPutAll: definedEntities size asString;
		nextPutAll: ' defined entities / ';
		nextPutAll: stubEntities size asString;
		nextPutAll: ' stub entities)'
]

{ #category : 'accessing' }
MultiModelEntity >> searchedModels [

	^ searchedModels
]

{ #category : 'accessing' }
MultiModelEntity >> stubEntities [

	^ stubEntities
]
