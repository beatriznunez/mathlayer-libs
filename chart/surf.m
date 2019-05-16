function out = surf(x,y,z,o)
	
	[x y z o] = norm3dArgs(x,y,z,o,'surf',nargin)
	out = gen3d(x,y,z,o)
	
end