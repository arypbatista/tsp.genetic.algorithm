#
# Copyright (C) 2013 Ary Pablo Batista <arypbatista@gmail.com>, 
#                    Rodrigo Oliveri <rodrigooliveri10@gmail.com>
#
# This file is part of TSPGeneticAlgorithm (hereinafter, this program).
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

require "./classes/TSPGeneticAlgorithm.rb"
require "./classes/TSPBruteForceAlgorithm.rb"
require "./support/TSPGeneticAlgorithmSerializer.rb"
require "./support/RGLGraphs.rb"
require 'fileutils'
require "./GraphTest.rb"

TEST_BRUTE_FORCE = false

OUTPUT_DIR = "output"

if not Dir.exists?(OUTPUT_DIR)
  begin
    Dir.mkdir(OUTPUT_DIR)
  rescue Exception => e
    puts "Couldn't create ouput folder. Exiting..."
    exit 1
  end    
end
  


SAMPLES_DIR = "samples"
GRAPHS = [JSONGraphTest.new("graph1"),
          #JSONGraphTest.new("graph2"),
          JSONGraphTest.new("graph3"),
          #JSONGraphTest.new("graph4"),
          JSONGraphTest.new("complex1"),
          #JSONGraphTest.new("complex2"),
          JSONGraphTest.new("complex3"),
          #RandomGraphTest.new(),
          #RandomGraphTest.new(),
          RandomGraphTest.new()
          ]

GRAPHS.each { |graph_test|  
  puts "############################################"
  puts "TSPAlgorithm for " + graph_test.name
  puts "############################################"
  print "Testing algorithm... "
  start_time = Time.now
  algorithm = TSPGeneticAlgorithm.new(graph_test.graph, graph_test.population, graph_test.generations, graph_test.crossover_rate, graph_test.mutation_rate)
  best_fitness = algorithm.run()
  genetic_time = (Time.now - start_time)  
  print "OK\n"
  puts algorithm.to_s()  
  puts "-----------------------------------"
  puts "Elapsed time: " + genetic_time.to_s()
  if TEST_BRUTE_FORCE
    puts ""
    puts "############################################"
    puts "BruteForce Algorithm for " + graph_test.name
    puts "############################################"
    print "Testing algorithm... "
    start_time = Time.now
    result = TSPBruteForceAlgorithm.new().run(graph_test.graph)
    brute_time = (Time.now - start_time)
    print "OK\n"
    puts result.to_s
    puts "Elapsed time: " + brute_time.to_s()
    
    if brute_time < genetic_time
      puts " "
      puts "############################################"
      puts "#####    ##    ## ## ######  ###############"
      puts "##### ##### ## ## ## ######  ###############"
      puts "#####   ###    ## ## #######################"
      puts "##### ##### ## ## ##    ###  ###############"
      puts "############################################"
    else
      
    end
  end
  puts ""
  if graph_test.respond_to? 'known_solution'
    puts "############################################"
    puts "Known solution path: " + graph_test.known_solution.to_s()
    weight = graph_test.known_solution_weight
    puts "Known solution weight: " + weight.to_s()
    puts "Relation with Genetic best solution: " + (best_fitness.accumulated_weight.to_f() / weight.to_f()).to_s()
    puts "Relation with Genetic worst solution: " + (algorithm.worst_fitness.accumulated_weight.to_f() / weight.to_f()).to_s() 
  end
  puts ""
  print "Generating graph images... "
  if graph_test.respond_to? 'known_solution'
    graph_test.graph.colorized_write_to_graphic_file("png", OUTPUT_DIR + "/" + graph_test.name + "_known", graph_test.known_solution.first, graph_test.known_solution.last, graph_test.known_solution)  
  end
  graph_test.graph.colorized_write_to_graphic_file("png", OUTPUT_DIR + "/" + graph_test.name, best_fitness.origin_node, best_fitness.end_node, best_fitness.visited_nodes)
  algorithm.minimum_spanning_tree.colorized_write_to_graphic_file("png", OUTPUT_DIR + "/" + graph_test.name + "_mst")
  print "OK\n"
  puts ""
}
