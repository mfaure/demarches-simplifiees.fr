import { useCallback, useRef, useEffect } from 'react';
import type { LngLatBoundsLike } from 'maplibre-gl';
import DrawControl from '@mapbox/mapbox-gl-draw';
import type { FeatureCollection } from 'geojson';

import { useMapLibre } from '../../shared/maplibre/MapLibre';
import {
  useFitBounds,
  useEvent,
  useMapEvent
} from '../../shared/maplibre/hooks';
import {
  filterFeatureCollection,
  findFeature,
  getBounds
} from '../../shared/maplibre/utils';
import {
  SOURCE_SELECTION_UTILISATEUR,
  CreateFeatures,
  UpdateFatures,
  DeleteFeatures
} from '../hooks';

export function DrawLayer({
  featureCollection,
  createFeatures,
  updateFeatures,
  deleteFeatures,
  enabled
}: {
  featureCollection: FeatureCollection;
  createFeatures: CreateFeatures;
  updateFeatures: UpdateFatures;
  deleteFeatures: DeleteFeatures;
  enabled: boolean;
}) {
  const map = useMapLibre();
  const drawRef = useRef<DrawControl | null>();

  useEffect(() => {
    if (!drawRef.current && enabled) {
      const draw = new DrawControl({
        displayControlsDefault: false,
        controls: {
          point: true,
          line_string: true,
          polygon: true,
          trash: true
        }
      });
      map.addControl(draw as any, 'top-left');
      draw.set(
        filterFeatureCollection(featureCollection, SOURCE_SELECTION_UTILISATEUR)
      );
      drawRef.current = draw;

      for (const [selector, translation] of translations) {
        const element = document.querySelector(selector);
        if (element) {
          element.setAttribute('title', translation);
        }
      }
    }

    return () => {
      if (drawRef.current) {
        map.removeControl(drawRef.current as any);
        drawRef.current = null;
      }
    };
  }, [enabled]);

  const onSetId = useCallback(({ detail }) => {
    drawRef.current?.setFeatureProperty(detail.lid, 'id', detail.id);
  }, []);
  const onAddFeature = useCallback(({ detail }) => {
    drawRef.current?.add(detail.feature);
  }, []);
  const onDeleteFature = useCallback(({ detail }) => {
    drawRef.current?.delete(detail.id);
  }, []);

  useMapEvent('draw.create', createFeatures);
  useMapEvent('draw.update', updateFeatures);
  useMapEvent('draw.delete', deleteFeatures);

  useEvent('map:internal:draw:setId', onSetId);
  useEvent('map:internal:draw:add', onAddFeature);
  useEvent('map:internal:draw:delete', onDeleteFature);

  useExternalEvents(featureCollection, {
    createFeatures,
    updateFeatures,
    deleteFeatures
  });

  return null;
}

function useExternalEvents(
  featureCollection: FeatureCollection,
  {
    createFeatures,
    updateFeatures,
    deleteFeatures
  }: {
    createFeatures: CreateFeatures;
    updateFeatures: UpdateFatures;
    deleteFeatures: DeleteFeatures;
  }
) {
  const fitBounds = useFitBounds();

  const onFeatureFocus = useCallback(
    ({ detail }) => {
      const { id, bbox } = detail;
      if (id) {
        const feature = findFeature(featureCollection, id);
        if (feature) {
          fitBounds(getBounds(feature.geometry));
        }
      } else if (bbox) {
        fitBounds(bbox);
      }
    },
    [featureCollection, fitBounds]
  );

  const onFeatureCreate = useCallback(
    ({ detail }) => {
      const { geometry, properties } = detail;

      if (geometry) {
        createFeatures({
          features: [{ type: 'Feature', geometry, properties }],
          external: true
        });
      }
    },
    [createFeatures]
  );

  const onFeatureUpdate = useCallback(
    ({ detail }) => {
      const { id, properties } = detail;
      const feature = findFeature(featureCollection, id);

      if (feature) {
        feature.properties = { ...feature.properties, ...properties };
        updateFeatures({ features: [feature], external: true });
      }
    },
    [featureCollection, updateFeatures]
  );

  const onFeatureDelete = useCallback(
    ({ detail }) => {
      const { id } = detail;
      const feature = findFeature(featureCollection, id);

      if (feature) {
        deleteFeatures({ features: [feature], external: true });
      }
    },
    [featureCollection, deleteFeatures]
  );

  useEffect(() => {
    fitBounds(featureCollection.bbox as LngLatBoundsLike);
  }, []);

  useEvent('map:feature:focus', onFeatureFocus);
  useEvent('map:feature:create', onFeatureCreate);
  useEvent('map:feature:update', onFeatureUpdate);
  useEvent('map:feature:delete', onFeatureDelete);
}

const translations = [
  ['.mapbox-gl-draw_line', 'Tracer une ligne'],
  ['.mapbox-gl-draw_polygon', 'Dessiner un polygone'],
  ['.mapbox-gl-draw_point', 'Ajouter un point'],
  ['.mapbox-gl-draw_trash', 'Supprimer']
];
