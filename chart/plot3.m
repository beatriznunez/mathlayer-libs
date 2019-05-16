function out = plot3(x,y,z,o)

	[x y z o] = norm3dArgs(x,y,z,o,'plot3')
	out = gen3d(x,y,z,o)

end