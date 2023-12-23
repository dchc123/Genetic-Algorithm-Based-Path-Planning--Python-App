import numpy as np

def ant_colony_optimization(start, end, environment, n_ants=10, max_iter=100, alpha=1, beta=1, evaporation_rate=0.5, q=1):
    """
    Perform Ant Colony Optimization to find the optimal route between two points in a 2D numpy array.
    
    Args:
    - start: tuple (x, y) representing the starting point
    - end: tuple (x, y) representing the ending point
    - environment: 2D numpy array representing the environment, where 0 represents obstacles and values other than 0 represent the altitude
    - n_ants: number of ants
    - max_iter: maximum number of iterations
    - alpha: pheromone weight
    - beta: heuristic weight
    - evaporation_rate: pheromone evaporation rate
    - q: pheromone constant
    
    Returns:
    - path: list of tuples (x, y) representing the optimal path found
    """
    
    # Create pheromone trails and initialize them to a small value
    pheromone = np.ones_like(environment) * 0.01
    
    # Create a list to store the best path found so far
    best_path = None
    best_path_quality = -np.inf
    
    # Iterate for a maximum number of iterations
    for iteration in range(max_iter):
        # Initialize the ants at the starting point
        ants = [start] * n_ants
        
        # Initialize the distances and altitudes for each ant
        distances = np.zeros(n_ants)
        altitudes = np.zeros(n_ants)
        
        # Move the ants to the next position until they reach the target or hit an obstacle
        while True:
            # Compute the probabilities for each ant to move to the next position
            probabilities = []
            for ant in ants:
                row, col = ant
                neighbors = []
                if row > 0 and environment[row-1, col] != 0:
                    neighbors.append((row-1, col))
                if row < environment.shape[0]-1 and environment[row+1, col] != 0:
                    neighbors.append((row+1, col))
                if col > 0 and environment[row, col-1] != 0:
                    neighbors.append((row, col-1))
                if col < environment.shape[1]-1 and environment[row, col+1] != 0:
                    neighbors.append((row, col+1))
                probabilities.append([pheromone[n[0], n[1]]**alpha * (1/environment[n[0], n[1]])**beta for n in neighbors])
            
            # Choose the next position for each ant based on the
            # probabilities
            for i in range(n_ants):
                row, col = ants[i]
                neighbors = []
                if row > 0 and environment[row-1, col] != 0:
                    neighbors.append((row-1, col))
                if row < environment.shape[0]-1 and environment[row+1, col] != 0:
                    neighbors.append((row+1, col))
                if col > 0 and environment[row, col-1] != 0:
                    neighbors.append((row, col-1))
                if col < environment.shape[1]-1 and environment[row, col+1] != 0:
                    neighbors.append((row, col+1))
                if len(neighbors) == 0:
                    # Ant has reached an obstacle or the edge of the environment
                    distances[i] = np.inf
                else:
                    probabilities[i] /= sum(probabilities[i])
                    next_position = neighbors[np.random.choice(len(neighbors), p=probabilities[i])]
                    ants[i] = next_position
                    distances[i] += 1
                    altitudes[i] += environment[next_position[0], next_position[1]]
                    
                    if next_position == end:
                        # Ant has reached the target
                        if best_path is None or (altitudes[i]/distances[i]) > best_path_quality:
                            # Update the best path if the current path is better
                            best_path = ants[:i+1]
                            best_path_quality = altitudes[i]/distances[i]
                        break
            
            if best_path is not None:
                break
        
        # Update the pheromone trails based on the quality of the solutions found by the ants
        delta_pheromone = np.zeros_like(pheromone)
        for ant in ants:
            delta_pheromone[ant[0], ant[1]] += q / distances[i]
        pheromone = (1-evaporation_rate) * pheromone + delta_pheromone
        
    return best_path

environment = np.array([[0, 0, 1, 1, 1],
                        [0, 0, 1, 0, 1],
                        [0, 0, 1, 0, 1],
                        [0, 1, 1, 0, 1],
                        [0, 0, 0, 0, 1]])

start = (0, 0)
end = (4, 4)
path = ant_colony_optimization(start, end, environment)
print(path)