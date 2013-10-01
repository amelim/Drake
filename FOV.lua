--FOV.lua
--Lighting based on Monoco lighting engine
--https://www.facebook.com/notes/monaco/line-of-sight-in-a-tile-based-world/411301481995

--construct a big list of all "forward facing" edges


--Next, I link up each of these edges. So now each tile-length edge knows about its neighbors: 
--each has a "next" and a "previous" edge. Some edges are dead-ends, though: they don't have a next or a previous.