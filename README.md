# tsp.genetic.algorithm

Genetic algorithm for solving the **Travelling Salesman Problem (TSP)** in Ruby.

Given a weighted graph, the algorithm evolves a population of candidate tours to find a low-weight Hamiltonian cycle — a route that visits every vertex once and returns to the start.

## Authors

- Ary Pablo Batista — arypbatista@gmail.com
- Rodrigo Oliveri — rodrigooliveri10@gmail.com

## License

GNU GPL v3. See [license.txt](license.txt).

## Requirements

- Ruby
- [RGL](https://github.com/monora/rgl) (Ruby Graph Library) — used for graph representation, minimum spanning tree, and Graphviz image output
- Graphviz (for rendering PNGs of result graphs)

Install gems:

```bash
ruby gem-install.rb
```

## Usage

Run the main driver:

```bash
ruby Main.rb
```

Output PNGs (solution tour, known solution, minimum spanning tree) are written to `output/`.

### Configuring test graphs

Test cases live in [GraphTest.rb](GraphTest.rb). Edit the `GRAPHS` array in [Main.rb](Main.rb) to pick inputs:

- `JSONGraphTest.new("graph1")` — loads `samples/graph1.json`
- `RandomGraphTest.new(seed)` — generates a random graph; optionally forced strongly-connected with an embedded known-optimal tour for benchmarking

Sample JSON format (see [samples/](samples/)):

```json
{
  "directed": false,
  "vertices": ["A", "B", "C", "D"],
  "edges": [
    {"source": 1, "target": 2, "weight": 33},
    {"source": 2, "target": 3, "weight": 34},
    {"source": 3, "target": 0, "weight": 45}
  ]
}
```

## Algorithm parameters

Defaults defined in [GraphTest.rb](GraphTest.rb):

| Parameter | Default | Meaning |
|-----------|---------|---------|
| `population` | 256 | Individuals per generation |
| `generations` | 96 | Maximum generations before stopping |
| `crossover_rate` | 0.7 | Probability of crossover between two parents |
| `mutation_rate` | 0.01 | Per-bit mutation probability |

## Project structure

```
framework/    Generic GA framework (Chromosome, GeneticEntity, GeneticAlgorithm)
classes/      TSP-specific subclasses (TSPGeneticAlgorithm, Traveller)
support/      Utilities: RGL graph helpers, JSON I/O, bit-array helpers, serialization
samples/      Example input graphs in JSON
Main.rb       Entry point — runs GA over configured GRAPHS, writes results
GraphTest.rb  Test-case builders (JSON-loaded, randomly-generated)
gem-install.rb Installs required gems
```

### Framework ([framework/](framework/))

- **[Chromosome.rb](framework/Chromosome.rb)** — bit-array chromosome with configurable gene sizes; supports crossover (single-point, range swap) and per-bit mutation.
- **[GeneticEntity.rb](framework/GeneticEntity.rb)** — base class for individuals; wraps a `Chromosome` and exposes `fitness`.
- **[GeneticAlgorithm.rb](framework/GeneticAlgorithm.rb)** — generic evolutionary loop: roulette-wheel selection, crossover, mutation, elitism tracking of the best individual across generations. Subclasses override `scoreMember` and `isSolution?`.

### TSP implementation ([classes/](classes/))

- **[Traveller.rb](classes/Traveller.rb)** — decodes a chromosome into a sequence of travel decisions. Starting from an initial vertex, at each step it chooses an unvisited adjacent vertex using a gene as an index modulo the eligible-adjacents count. Records `visited_nodes`, `accumulated_weight`, and whether the tour closed back (`arrived`).
- **[TSPGeneticAlgorithm.rb](classes/TSPGeneticAlgorithm.rb)** — TSP-specific GA. Fitness rewards:
  1. Number of visited vertices (main term, up to 1000).
  2. Closing the tour (arrival bonus, 40% of visited score).
  3. Low total weight (up to 100, relative to graph total weight).

  Upper bound uses the graph's minimum spanning tree total weight; `isSolution?` stops early when a member reaches that bound.

### Support ([support/](support/))

- **RGLGraphs.rb** — RGL extensions: weights, total weight, MST, colorized Graphviz output (start/end vertices + tour path highlighted).
- **JSONUtils.rb** — JSON graph loader.
- **ArrayUtils.rb / IntegerUtils.rb** — bit-array ↔ integer conversions used by `Chromosome`.
- **TSPGeneticAlgorithmSerializer.rb** — run serialization.

## Output

For each graph in the run, `Main.rb` prints:

- Best tour found, its accumulated weight, and elapsed time.
- If a known solution exists: ratio of GA best/worst vs. known-optimal weight.

And writes to `output/`:

- `<name>.png` — graph with best GA tour highlighted.
- `<name>_known.png` — known-optimal tour (if available).
- `<name>_mst.png` — minimum spanning tree.
