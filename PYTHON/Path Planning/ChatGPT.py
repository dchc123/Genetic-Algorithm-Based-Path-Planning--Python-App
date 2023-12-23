import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt

# Define the environment as a 2D numpy array
# where 0 represents low altitude regions (obstacles)
# and non-zero values represent the altitude
environment = np.random.randint(low=1, high=10, size=(10, 10))

# Define the genetic algorithm parameters
POPULATION_SIZE = 10
GENE_LENGTH = 5
CROSSOVER_RATE = 0.8
MUTATION_RATE = 0.01
NUM_GENERATIONS = 100

def concatenate(start, goal, individual):
    individual_full=individual.copy()

    individual_full.insert(0,start)
    individual_full.append(goal)

    return individual_full

# Define the fitness function
def fitness(individual, start_point, goal_point):
    #add start and goal point to assess fitness
    individual_full=concatenate(start_point,goal_point,individual)

    # Calculate the path length
    path_length = 0
    for i in range(len(individual_full) - 1):
        x1, y1 = individual_full[i]
        x2, y2 = individual_full[i+1]
        path_length += np.sqrt((x2-x1)**2 + (y2-y1)**2)

    # Calculate the number of obstacles hit
    obstacles_hit = 0
    for x, y in individual_full:
        if environment[x, y] == 0:
            obstacles_hit += 1

    # Calculate the average altitude
    avg_altitude = np.mean(environment[[x for x, y in individual_full], [y for x, y in individual_full]])

    # Calculate the fitness as a weighted sum of the above metrics
    fitness = 10000/path_length - 1000*obstacles_hit + avg_altitude

    return fitness

def generate_start():
    gene = []
    np.random.seed(1)
    x = np.random.randint(low=0, high=environment.shape[0], size=1)
    np.random.seed(2)
    y = np.random.randint(low=0, high=environment.shape[0], size=1)
    if environment[x, y] != 0:
        gene=(x[0], y[0])
    return gene

def generate_goal():
    gene = []
    np.random.seed(3)
    x = np.random.randint(low=0, high=environment.shape[0], size=1)
    np.random.seed(4)
    y = np.random.randint(low=0, high=environment.shape[0], size=1)
    if environment[x, y] != 0:
        gene=(x[0], y[0])
    return gene


# Define the genetic algorithm functions
def generate_individual():
    # Generate a random sequence of waypoints
    individual = []
    while len(individual) < GENE_LENGTH:
        x, y = np.random.randint(low=0, high=environment.shape[0], size=2)
        if environment[x, y] != 0:
            individual.append((x, y))
    return individual

def crossover(parent1, parent2):
    # Perform one-point crossover
    child1 = parent1.copy()
    child2 = parent2.copy()
    if np.random.rand() < CROSSOVER_RATE:
        crossover_point = np.random.randint(1, GENE_LENGTH)
        child1 = parent1[:crossover_point] + parent2[crossover_point:]
        child2 = parent2[:crossover_point] + parent1[crossover_point:]
    return child1, child2

def mutate(individual):
    # Perform random mutation
    if np.random.rand() < MUTATION_RATE:
        index = np.random.randint(0, GENE_LENGTH)
        x, y = np.random.randint(low=0, high=environment.shape[0], size=2)
        if environment[x, y] != 0:
            individual[index] = (x, y)
    return individual

def select_parents(population, start_point, goal_point):
    # Perform roulette wheel selection
    fitnesses = [fitness(individual, start_point, goal_point) for individual in population]
    sum_fitness = sum(fitnesses)
    probabilities = [fitness/sum_fitness for fitness in fitnesses]
    parents = []
    for i in range(2):
        while True:
            index = np.random.choice(len(population), p=probabilities)
            if population[index] not in parents:
                parents.append(population[index])
                break
    return parents, fitnesses

# Define the main function that runs the genetic algorithm
def main(start_point, goal_point):
    # Generate the initial population

    population = [generate_individual() for _ in range(POPULATION_SIZE)]

    global_best=0

    # Run the genetic algorithm for a fixed number of generations
    for generation in range(NUM_GENERATIONS):
        # Select parents
        parents, fitnesses = select_parents(population, start_point, goal_point)

        # Create the next generation by crossover and mutation
        next_generation = []
        for i in range(0, POPULATION_SIZE, 2):
            parent1 = parents[0]
            parent2 = parents[1]
            child1, child2 = crossover(parent1, parent2)
            child1 = mutate(child1)
            child2 = mutate(child2)
            next_generation.append(child1)
            next_generation.append(child2)

        # Replace the current population with the next generation
        population = next_generation

        # Print the best individual in this generation
        best_fitness_index=fitnesses.index(max(fitnesses))

        best_individual = population[best_fitness_index]
        print(f"Generation {generation + 1}: {best_individual}, Fitness: {fitness(best_individual, start_point, goal_point)}")

        if fitness(best_individual, start_point, goal_point)>global_best:
            global_best=fitness(best_individual, start_point, goal_point)
            best_solution=best_individual

    return global_best, best_solution

if __name__ == "__main__":
    start_point = generate_start()
    goal_point = generate_goal()

    global_best, best_solution=main(start_point, goal_point)

    print(global_best)

    best_solution=concatenate(start_point,goal_point,best_solution)

    print(best_solution)


    # Plot the environment and the optimal path

    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    x, y = np.meshgrid(np.arange(environment.shape[0]), np.arange(environment.shape[1]))
    ax.plot_surface(x, y, environment, cmap='terrain')
    xs, ys = zip(*best_solution)
    ax.plot(xs, ys, color='red', linewidth=2)
    plt.scatter(start_point[0], start_point[1], 0, marker='x')
    plt.show()

