// https://playcode.io/new

// Initializing variable as an Object value.
const obj = {"a":{"b":{"c":"1"},"e":6},"d":2};
console.log('Object: '+JSON.stringify(obj));
let value = getValue(obj,'a');
console.log('Value : '+value);

// Calling function with parameter as an object and a required key to get the value if exists otherwise blank value will return
function getValue(obj,requiredKey) {

// Defining Map to set,get value of keys present in the object
const keyToValueMap = new Map();

// Calling function with parameter as an object to set the keys and values in the map;
getMapWithKeysValues(obj,requiredKey);

  // Initializing the required value as blank
  let requiredValue = '';

  // Checking if required key is present in the map or not
  if(keyToValueMap.has(requiredKey)){
    // putting the value got from the map for the required key
      requiredValue = keyToValueMap.get(requiredKey);
   }
 // Checking if required is an object or not, if yes then showing value using function JSON.stringify
  if(requiredValue !== '' && typeof(requiredValue === 'object')){
    requiredValue = JSON.stringify(requiredValue);
  }
// returning the value whether its blank or object or string or number..  
return requiredValue;

  // Defining the function inside the main function to set the the values and keys in the map from the given object
  function getMapWithKeysValues(obj,requiredKey) {
    
    // For loop to iterate in each keys
    for (const [key, value] of Object.entries(obj)) {
      // if value of a key is an object then calling the same function to set their keys and values in the map
      if(typeof(value) === 'object'){
        // Setting the key and value in the map
        keyToValueMap.set(key,value);
        getMapWithKeysValues(value);
      }else{
        keyToValueMap.set(key,value);
      }
    }
  }
}