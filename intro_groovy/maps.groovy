def person = [
    name: "Alice",
    age : 30,
    city: "London",
    job : "Data Scientist"
]

String describePerson(Map person) {
    def name = person.name ?: "Unknown"
    def age = person.age ?: "unspecified age"
    def city = person.city ?: "an unknown city"
    def jobInfo = person.job ? " and works as a ${person.job}" : ""
    
    return "$name is $age years old, lives in $city$jobInfo."
}

println describePerson(person)