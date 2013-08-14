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

require 'rgl/adjacency'
require 'rgl/dot' 
require './support/ArrayUtils.rb'

module RGL
  
  # Weigthed edges to extend default rgl edge implementation
  module Edge
    
    # Directed pair (source -> target) with associated weight.
    class DirectedEdge
      attr_accessor :source, :target, :weight
 
      # Can be used to create an edge from a two element array.
      def self.[](*a)
        if (a.size < 3)
          new(a[0],a[1], 1)
        else
          new(a[0], a[1], a[2])
        end
      end
            
      def initialize (source, target, weight=1)
        @source, @target, @weight = source, target, weight
      end
       
      # Two directed edges (u,v) and (x,y) are equal iff u == x and v == y. eql?
      # is needed when edges are inserted into a Set. eql? is aliased to ==.
      def eql?(edge)
        @source == edge.source and @target == edge.target and @weight == edge.weight 
      end
      alias == eql?

      # Returns (v,u) if self == (u,v).
      def reverse
        self.class.new(@target, @source, @weight)
      end
 
      # Edges can be indexed. edge[0] == edge.source, edge[n] == edge.target for
      # all n>0. Edges can thus be used as a two element array.
      def [](index)
        if index.zero?
          return @source 
        elsif index == 1
          return @target
        else
          return @weight
        end 
      end
      
      def is_target(vertex)
        @target == vertex
      end
      
      def is_source(vertex)
        @source == vertex
      end
      
      # Returns the array [source, target, weight].
      def to_a2; [@source, @target, @weight]; end
      
      # DirectedEdge[1,2,23].to_s == "(1-[23]-2)"
      def to_s
        "(#{source}-[#{weight}]-#{target})"
      end
      
      # Sort support is dispatched to the <=> method of Array
      def <=> e
        (self.to_a2 <=> e.to_a2)
      end
    end
          
    # An undirected edge is simply an undirected pair (source, target) used in
    # undirected graphs. UnDirectedEdge[u,v] == UnDirectedEdge[v,u]
    class UnDirectedEdge < DirectedEdge
      def eql?(edge)
        super or (@target == edge.source and @source == edge.target and @weight == edge.weight)
      end
      
      def hash
        @source.hash ^ @target.hash ^ @weight.hash
      end
      
      def is_target(vertex)
        super or @source == vertex
      end
      
      def is_source(vertex)
        super or @target == vertex
      end
      
      # UnDirectedEdge[1,2,23].to_s == "(1=[23]=2)"
      def to_s; "(#{@source}=[#{@weight}]=#{@target})"; end
    end

  end                           # Edge
  
  module Graph
    def to_dot_colorized_graph (origin_node, end_node, path=[], params = {})
      params['name'] ||= self.class.name.gsub(/:/,'_')
      fontsize   = params['fontsize'] ? params['fontsize'] : '8'
      #graph      = DOT::Graph.new(params, DOT::GRAPH_OPTS + ["dpi"]) 
      graph      = (directed? ? DOT::Digraph : DOT::Graph).new(params, DOT::GRAPH_OPTS + ["dpi"]) #DOT::Subgraph
      edge_class = directed? ? DOT::DirectedEdge : DOT::Edge
      each_vertex do |v|
        name = v.to_s
        
        node_color = "white"
        node_color = "yellow" if path.include?(v)
        node_color = "orange" if (origin_node == v)
        node_color = "red" if (end_node == v)
        node_color = "green" if (origin_node == end_node) and (origin_node == v)
        
        graph << DOT::Node.new('name'     => name,
                               'fontsize' => fontsize,
                               'label'    => name,
                               'style'    => "filled",
                               'fillcolor' => node_color)
      end
      each_edge do |u,v,w|
        edge_color = "black"
        edge_color = "red" if u != v and (path.include_subarray?([u,v]) || path.include_subarray?([v,u]))
        graph << edge_class.new('from'     => u.to_s,
                                'to'       => v.to_s,
                                'label' => w.to_s,
                                'fontsize' => fontsize,
                                'color' => edge_color)
      end
      return graph
    end
    
    def colorized_write_to_graphic_file(fmt='png', dotfile="graph", origin_node=nil, end_node=nil, path=[])
      
      extraparams =  { "dpi" => "1200", "ranksep" => "0.3", "size" => "6.0,6.0", "rankdir" => "TB" }
      
      root = File.absolute_path("./")
      src = root + "/" + dotfile + ".dot"
      out = root + "/" + dotfile + "." + fmt
       
      File.open(src, 'w') do |f|
        f << self.to_dot_colorized_graph(origin_node, end_node, path, extraparams).to_s << "\n"
      end
      
      system( "dot -T#{fmt} #{src} -o #{out}" )
      #puts %x( "dot -T#{fmt} \"#{src}\" -o \"#{out}\"" )
      out
    end
  
    # Return the array of edges (DirectedEdge or UnDirectedEdge) of the graph
    # using each_edge, depending whether the graph is directed or not.
    def edges
      result = []
      c = edge_class
      each_edge { |u,v,w| result << c.new(u,v,w) }
      result
    end
    
    def edges_for(vertex)
      result = []
      c = edge_class
      each_edge do 
        |u,v,w|
        if u == vertex or (not directed? and v == vertex)
          result << c.new(u,v,w)
        end 
      end
      result
    end
        
    # each_edge with weigthed edges
    def each_edge (&block)
      if directed?
        each_vertex { |u|
          each_adjacent(u) { |v| yield u,v,self.get_weight(u,v) }
        }
      else
        each_edge_aux(&block)       # concrete graphs should to this better
      end
    end
    
    def total_weight
      acc = 0
      @weights_dict.each_value {|v| acc = acc + v}
      acc
    end
    
    def get_weight(u, v)
      @weights_dict[[u,v].to_set] 
    end
    
    def set_weight(u,v,w)
      @weights_dict[[u,v].to_set] = w
    end
    
    # each_edge_aux with weigthed edges
    def each_edge_aux
       # needed in each_edge
       visited = Hash.new
       each_vertex { |u|
         each_adjacent(u) { |v|
           edge = UnDirectedEdge.new u,v,get_weight(u,v)
           unless visited.has_key? edge
             visited[edge]=true
             yield u, v, edge.weight
           end
         }
       }
     end
     
    # Convert a general graph to an AdjacencyGraph.  If the graph is directed,
    # returns a DirectedAdjacencyGraph; otherwise, returns an AdjacencyGraph.

    def to_adjacency
      result = (directed? ? DirectedAdjacencyGraph : AdjacencyGraph).new
      each_vertex { |v| result.add_vertex(v) }
      each_edge { |u,v,w| result.add_edge(u, v, w) }
      result
    end

    # Return a new DirectedAdjacencyGraph which has the same set of vertices.
    # If (u,v) is an edge of the graph, then (v,u) is an edge of the result.
    #
    # If the graph is undirected, the result is self.

    def reverse
      return self unless directed?
      result = DirectedAdjacencyGraph.new
      each_vertex { |v| result.add_vertex v }
      each_edge { |u,v,w| result.add_edge(v, u, w) }
      result
    end
    
    def minimum_spanning_tree
      mst = RGL::DirectedAdjacencyGraph.new()
      
      def pick_minimum_edge(edges)
        edges.sort! { |e1, e2| e1.target <=> e2.target }
        return edges.at(0)
      end
      
      def other_vertex(edge, vertex)
        if edge.target == vertex
          return edge.source
        else
          return edge.target
        end
      end
      
      def vertex_not_in_nodes(edge, nodes)
        (nodes.include? edge.target) ? edge.source : edge.target
      end
      
      def edges_for_nodes(nodes, graph)
        edges = [] 
        nodes.each do 
          |node|
          node_edges = graph.edges_for(node).select { 
              |edge| 
              not nodes.include?(other_vertex(edge, node)) 
            }
          edges.push(*node_edges)
        end
        return edges
      end
      
      current_node = self.vertices.at(rand(self.vertices.size - 1))
      visited_nodes = [current_node]
      
      edges = edges_for_nodes(visited_nodes, self)
      while edges.size != 0 do
        edge = pick_minimum_edge(edges)
        target = vertex_not_in_nodes(edge, visited_nodes)
        source = other_vertex(edge, target)
        directed_edge = edge_class.new(source, target, edge.weight)
        mst.add_edges(directed_edge)
        visited_nodes.push(directed_edge.target)
        edges = edges_for_nodes(visited_nodes, self)
      end
      
      return mst      
    end
  end

  module MutableGraph
    def add_edge (u, v, w)
      raise NotImplementedError
    end
    
    def add_edges (*edges)      
      edges.each { |edge| add_edge(edge[0], edge[1], edge[2])}
    end
  end
    
  class DirectedAdjacencyGraph
    def self.[] (*a)
      result = new
      0.step(a.size-1, 2) { |i| result.add_edge(a[i], a[i+1], 1) }
      result
    end
    
    def initialize(edgelist_class = Set, *other_graphs)
      @weights_dict = Hash.new
      @edgelist_class = edgelist_class
      @vertice_dict   = Hash.new
      other_graphs.each do |g|
        g.each_vertex {|v| add_vertex v}
        g.each_edge {|v,u,w| add_edge v,u,w}
      end
    end
    
    def basic_add_edge(u, v, w)
      @vertice_dict[u].add(v)
      self.set_weight(u,v,w)
    end
        
    def add_edge(u, v, w)
      add_vertex(u)                         # ensure key
      add_vertex(v)                         # ensure key
      basic_add_edge(u, v, w)
    end
  end
  
  class AdjacencyGraph < DirectedAdjacencyGraph
    def basic_add_edge(u, v, w)
      super
      @vertice_dict[v].add(u)
    end
  end
end