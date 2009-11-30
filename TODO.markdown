- Documentation
  - Introduction
    - overall example
  - Assertion 
    - scope
    - extensions (e.g. rack/test)
  - Yard
    - use yard to document the #assertion method used to define new assertions so the defined assertions will show up in the docs ( http://gnuu.org/2009/11/18/customizing-yard-templates/ )
    
- Assertion Macros
  - include/any/contains (array,hash, maybe string?)
    - perhaps able to take an enumerable and compare...
      { [1,2,3] }.contains(2,3) 
      { "the song that never ends" }.contains("never","ends")
