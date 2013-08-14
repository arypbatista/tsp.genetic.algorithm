require "./support/JSONUtils.rb"

DEFAULT_MUTATION_RATE = 0.01
DEFAULT_CROSSOVER_RATE = 0.7
DEFAULT_GENERATIONS = 96
DEFAULT_POPULATION = 256
DEFAULT_STRONGLY_CONNECTED = true
DEFAULT_GEN_KNOWN_SOLUTION = true

class GraphTest
  attr_accessor :name, :graph, :population, :generations, :crossover_rate, :mutation_rate
  def initialize(name, graph, population=DEFAULT_POPULATION, generations=DEFAULT_GENERATIONS, crossover_rate=DEFAULT_CROSSOVER_RATE, mutation_rate=DEFAULT_MUTATION_RATE)
    @name = name
    @graph = graph
    @population = population
    @generations = generations
    @crossover_rate = crossover_rate
    @mutation_rate = mutation_rate
  end
end

class RandomGraphTest < GraphTest
  @@MAX_NODES = 10
  @@MIN_NODES = 3
  @@MAX_EDGES = 8
  @@MAX_WEIGHT = 20
  @@MIN_WEIGHT = 4
  
  attr_accessor :generate_known_solution, :force_strongly_connected, :known_solution
  
  def initialize(seed=Random.new_seed, force_strongly_connected=DEFAULT_STRONGLY_CONNECTED, generate_known_solution=DEFAULT_GEN_KNOWN_SOLUTION, population=DEFAULT_POPULATION, generations=DEFAULT_GENERATIONS, crossover_rate=DEFAULT_CROSSOVER_RATE, mutation_rate=DEFAULT_MUTATION_RATE)
    @force_strongly_connected = force_strongly_connected
    @generate_known_solution = generate_known_solution
    @known_solution = []
    super("graph_id_" + seed.to_s(), generate_graph(seed), population, generations, crossover_rate, mutation_rate)
  end
  
  def generate_graph(seed)
    gen_graph = RGL::AdjacencyGraph.new
    
    random = Random.new(seed)
    vertex_count = random.rand(@@MAX_NODES - @@MIN_NODES) + @@MIN_NODES
    
    vertices = []
    vertex_count.times do |i|
      vertices.push(i)
    end
    
    vertices.each do |vertex|
      edge_count = random.rand(@@MAX_EDGES)
      edges = []
      unconnected_vertices = Array.new(vertices)
      edge_count.times do |i|
        if unconnected_vertices.size > 0
          if unconnected_vertices.size > 1
            other_vertex = unconnected_vertices.delete_at(random.rand(unconnected_vertices.size - 1))
          else
            other_vertex = unconnected_vertices.delete_at(0)
          end
          if not gen_graph.has_vertex?(other_vertex) or not gen_graph.adjacent_vertices(other_vertex).include?(vertex)
            edges.push([vertex, other_vertex, random.rand(@@MAX_WEIGHT - @@MIN_WEIGHT) + @@MIN_WEIGHT])
          end
        end
      end
      gen_graph.add_edges(*edges)      
    end
    
    if @generate_known_solution
      offset = ((@@MAX_WEIGHT - @@MIN_WEIGHT) * 0.3).ceil
      random_weight = -> {random.rand(@@MIN_WEIGHT + offset)}
    else
      random_weight = -> {random.rand(@@MAX_WEIGHT - @@MIN_WEIGHT) + @@MIN_WEIGHT}
    end
    
    if @force_strongly_connected
      previous = nil
      (vertices + [vertices[0]]).each do |vertex|
        if @generate_known_solution
          @known_solution << vertex
        end
        if previous
          if not gen_graph.has_edge?(previous, vertex)
            gen_graph.add_edges([previous, vertex, random_weight.call()])
          else
            if @generate_known_solution
              gen_graph.set_weight(previous, vertex, random_weight.call())
            end
          end
        end
        previous = vertex
      end
    end
    
    return gen_graph
  end
  
  def known_solution_weight()
    previous = nil
    sum = 0
    @known_solution.each do
      |vertex|
      if previous
        sum += @graph.get_weight(previous, vertex)
      end
      previous = vertex
    end 
    return sum
  end
end

class JSONGraphTest < GraphTest
  def initialize(name, population=DEFAULT_POPULATION, generations=DEFAULT_GENERATIONS, crossover_rate=DEFAULT_CROSSOVER_RATE, mutation_rate=DEFAULT_MUTATION_RATE)
    super(name, JSONGraph.new(SAMPLES_DIR + "/" + name + ".json").read(), 
          population, generations, crossover_rate, mutation_rate)
  end
end