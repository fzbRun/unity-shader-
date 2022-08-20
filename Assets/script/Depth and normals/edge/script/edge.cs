using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class edge : PostEffectsBase
{

    public Shader edgeShader;
    private Material edgeMaterial;
    public Material material
    {
        get
        {

            edgeMaterial = CheckShaderAndCreateMaterial(edgeShader, edgeMaterial);
            return edgeMaterial;

        }
    }

    [Range(0.0f, 1.0f)]
    public float edgesOnly = 0.0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    public float sampleDistance = 1.0f;

    public float sensitivityDepth = 1.0f;

    public float sensitivityNormal = 1.0f;

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        
        if(material != null)
        {

            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetFloat("_SampleDistance", sampleDistance);
            material.SetVector("_Sensitivity", new Vector4(sensitivityNormal, sensitivityDepth, 0.0f, 0.0f));

            Graphics.Blit(source, destination, material);

        }
        else
        {
            Graphics.Blit(source, destination);
        }

    }

}
