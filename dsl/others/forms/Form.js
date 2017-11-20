// Student
//  - name : String
//  - level : [Elementary, High]
//  - subjects
//    - name : String
//    - grade : Number


h('div.form',
  h('fieldset', { css: 'cols-2' },
    h('legend', 'Student'),
    h('div.grid.row',
      h('div.field', h('label', { 'for': 'student.firstName' }, 'First Name')
        h('input', { type: 'text', name: 'student.firstName', value: G('student.firstName') })
        h('input', { type: 'text', name: 'student.lastName', value: G('student.lastName') })
      )
      h('div.field', h('label', { 'for': 'student.firstName' }, 'Last Name')
        h('input', { type: 'text', name: 'student.lastName', value: G('student.lastName') })
      )
    ),

    h('div.grid.row',
      // ....
    )
  )
)

//Example DSL   
p.form('student', function(f) {
  f.fieldset('Student',  { cols: 2 }
    f.field('Name', 
      f.text('firstName'),
      f.text('lastName')
    ),
    
    f.field('Age',
      f.number('age')
    ),
    
    // New row will be generated automatically for next field
    f.field('Class', 
      f.suggest('class')
    )
  )
  
  f.fieldset('Marks', { cols: 2 },
    f.field('A'),
    f.field('B'),
    
    f.collection('marks', function(f) {
      f.fieldset({ cols: 2 },
        f.field(f.)
      )
    });
  )
});

//Example callback:

h.button('Save', { 'data-action': p.callback(function(a) {
  var studentForm = a.forms.student; // Form Object
  var data = a.request.body;
  
  var cleanedData = studentForm.clean(data);
  var student = db.load(cleanedData);
  
  db.save(student);
  
  a.context.student = student;
  
  a.refresh();
})});
