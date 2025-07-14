def isEven = { n -> n % 2 == 0 }
def square = { x -> x * x }

def numbers = [1, 2, 3, 4, 5, 6, 7, 8]
def evens = numbers.findAll(isEven)
def squaredEvens = evens.collect(square)

println "Original List: $numbers"
println "Even Numbers : $evens"
println "Squared Evens: $squaredEvens"