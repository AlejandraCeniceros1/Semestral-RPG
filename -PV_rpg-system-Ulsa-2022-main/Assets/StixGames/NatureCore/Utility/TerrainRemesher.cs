using System.Collections.Generic;
using UnityEngine;

namespace StixGames.NatureCore
{
    public class TerrainRemesher
    {
        public float SampleMultiplier = 1;

        private Terrain terrain;

        private float[,] heights;

        private int dataWidth;
        private int dataLength;
        private float sampleXCount;
        private float sampleYCount;
        private float maxHeight;
        private float sampleWidth;
        private float sampleLength;

        private readonly List<Vector3> vertices = new List<Vector3>();
        private readonly List<Vector3> normals = new List<Vector3>();
        private readonly List<Vector2> uvs = new List<Vector2>();
        private readonly List<int> triangles = new List<int>();

        private readonly Dictionary<Coordinate, int> indexLookup = new Dictionary<Coordinate, int>();

        public TerrainRemesher(Terrain terrain)
        {
            this.terrain = terrain;
        }

        /// <summary>
        /// Takes the terrain and converts it into meshes inside the local space of the terrain
        /// </summary>
        /// <returns></returns>
        public Mesh[] GenerateTerrainMesh()
        {
            var terrainData = terrain.terrainData;
            heights = terrainData.GetHeights(0, 0, terrainData.heightmapResolution, terrainData.heightmapResolution);

            dataWidth = heights.GetLength(0);
            dataLength = heights.GetLength(1);

            sampleXCount = dataWidth * SampleMultiplier - 1;
            sampleYCount = dataLength * SampleMultiplier - 1;

            //Calculate the step size / the distance between all vertices
            sampleWidth = terrainData.size.x / sampleXCount;
            sampleLength = terrainData.size.z / sampleYCount;
            maxHeight = terrainData.size.y;

            var meshList = new List<Mesh>();

            for (int x = 0; x < sampleXCount; x++)
            {
                for (int y = 0; y < sampleYCount; y++)
                {
                    if (vertices.Count + 4 > 65535)
                    {
                        meshList.Add(NextSubMesh());
                    }

                    var v0 = GetOrCreateVertex(x, y);
                    var v1 = GetOrCreateVertex(x + 1, y);
                    var v2 = GetOrCreateVertex(x + 1, y + 1);
                    var v3 = GetOrCreateVertex(x, y + 1);

                    triangles.Add(v0);
                    triangles.Add(v1);
                    triangles.Add(v2);

                    triangles.Add(v0);
                    triangles.Add(v2);
                    triangles.Add(v3);
                }
            }

            meshList.Add(NextSubMesh());

            return meshList.ToArray();
        }

        private Mesh NextSubMesh()
        {
            var mesh = new Mesh();
            mesh.name = "SubTerrain Mesh";

            mesh.SetVertices(vertices);
            mesh.SetUVs(0, uvs);
            mesh.SetNormals(normals);
            mesh.SetTriangles(triangles, 0);

            mesh.RecalculateBounds();

            vertices.Clear();
            uvs.Clear();
            normals.Clear();
            triangles.Clear();
            indexLookup.Clear();

            return mesh;
        }

        private int GetOrCreateVertex(int x, int y)
        {
            var coord = new Coordinate(x, y);
            if (indexLookup.ContainsKey(coord))
            {
                return indexLookup[coord];
            }

            var center = GetPosition(x, y);
            vertices.Add(center);
            uvs.Add(new Vector2(y / sampleYCount, x / sampleXCount));

            //Calculate normal
            var left = GetPosition(x - 1, y);
            var right = GetPosition(x + 1, y);
            var front = GetPosition(x, y - 1);
            var back = GetPosition(x, y + 1);

            var widthDiff = right - left;
            var lengthDiff = front - back;
            normals.Add(Vector3.Cross(lengthDiff, widthDiff));

            int index = vertices.Count - 1;
            indexLookup[coord] = index;
            return index;
        }

        private Vector3 GetPosition(float x, float y)
        {
            // Change the samples to fit the real terrain size
            var sampleX = x / SampleMultiplier;
            var sampleY = y / SampleMultiplier;
            
            if (sampleX < 0)
            {
                sampleX = 0;
            }

            if (sampleY < 0)
            {
                sampleY = 0;
            }

            if (sampleX > dataWidth - 1)
            {
                sampleX = dataWidth - 1;
            }

            if (sampleY > dataLength - 1)
            {
                sampleY = dataLength - 1;
            }

            //Interpolate
            var minX = Mathf.FloorToInt(sampleX);
            var maxX = Mathf.CeilToInt(sampleX);
            var minY = Mathf.FloorToInt(sampleY);
            var maxY = Mathf.CeilToInt(sampleY);
            var fracX = sampleX - minX;
            var fracY = sampleY - minY;
            var invFracX = 1 - fracX;
            var invFracY = 1 - fracY;

            var q11 = heights[minX, minY];
            var q12 = heights[minX, maxY];
            var q21 = heights[maxX, minY];
            var q22 = heights[maxX, maxY];

            var height = q11 * invFracX * invFracY +
                         q21 * fracX * invFracY +
                         q12 * invFracX * fracY +
                         q22 * fracX * fracY;

            return new Vector3(y * sampleLength, height * maxHeight, x * sampleWidth);
        }

        private struct Coordinate
        {
            public readonly int x, y;

            public Coordinate(int x, int y)
            {
                this.x = x;
                this.y = y;
            }

            public bool Equals(Coordinate other)
            {
                return x == other.x && y == other.y;
            }

            public override bool Equals(object obj)
            {
                if (ReferenceEquals(null, obj)) return false;
                return obj is Coordinate && Equals((Coordinate) obj);
            }

            public override int GetHashCode()
            {
                unchecked
                {
                    return (x * 397) ^ y;
                }
            }
        }
    }
}