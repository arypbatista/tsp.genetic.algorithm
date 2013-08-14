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

require './support/RGLGraphs.rb'
require 'rubygems'
require 'json'

class JSONVertexFactory
  def create(json_vertex)
    json_vertex
  end
end

class JSONGraph
  attr_accessor :filename
  
  def initialize(filename, vertex_factory=JSONVertexFactory.new)
    @filename = filename
    @vertex_factory = vertex_factory
  end
  
  def read()
    parsedGraph = JSON.parse(open(@filename).read)
    self.replace_references(parsedGraph)
    graph = (parsedGraph["directed"] ? RGL::DirectedAdjacencyGraph : RGL::AdjacencyGraph).new
    graph.add_edges(*parsedGraph["edges"])
    return graph
  end
  
  def replace_references(json_graph)
    vertices = Array.new
    json_graph["vertices"].each {|vertex| vertices.push(@vertex_factory.create(vertex)) }
    json_graph["vertices"] = vertices
      
    edges = Array.new
    json_graph["edges"].each { |edge| edges.push(self.build_edge(edge,  vertices))}
    json_graph["edges"] = edges
      
    json_graph["directed"] = json_graph["directed"] == 'true'
  end
  
  def build_edge(edge, vertex_list)
    [vertex_list[edge["source"]], vertex_list[edge["target"]], edge["weight"]]
  end
  
end
