@testset "prop graphs" begin
    hr1 = create_dir_graph(5)
    mat = [0 1 0; 1 0 0; 0 1 0] # 1<-->2<--3
    hr2 = create_dir_graph(mat)
    @test SimpleABM.all_neighbors(hr2, 1) == [2]
    @test Set(SimpleABM.in_neighbors(hr2, 2)) == Set([1,3])
    @test SimpleABM.out_neighbors(hr2, 3) == [2]
    gr1 = create_simple_graph(5)
    mat = sparse([1,2,2,3,3,4,4,5,5,1],[2,1,3,2,4,3,5,4,1,5],[1,1,1,1,1,1,1,1,1,1]) # pentagon 1--2--3--4--5--1 #
    gr2 = create_simple_graph(mat)
    @test Set(SimpleABM.all_neighbors(gr2, 2)) == Set([1,3])
end