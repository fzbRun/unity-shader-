using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class cameraMakeCubeMap : MonoBehaviour
{

    public GameObject sph;
    private Camera cam;

    // Start is called before the first frame update
    void Start()
    {

        cam = GetComponent<Camera>();
        if (sph != null)
        {
            Material mat = sph.GetComponent<Renderer>().material;
            if (mat != null)
            {
                RenderTexture cubeMap = new RenderTexture(1024, 1024, 16);
                cubeMap.dimension = UnityEngine.Rendering.TextureDimension.Cube;
                cam.RenderToCubemap(cubeMap);
                mat.SetTexture("_CubeMap",cubeMap);
            }
        }

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
