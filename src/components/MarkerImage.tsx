import React from 'react';
import { Image } from 'react-native';
import { ImageProps } from 'react-native';
import { useState } from 'react';

interface Props extends ImageProps {}

export const MarkerImage = (props: Props) => {
  const [isLoaded, setIsLoaded] = useState(false);

  return (
    <Image
      {...props}
      key={String(isLoaded)}
      onLoad={(event) => {
        props.onLoad?.(event);
        setIsLoaded(true);
      }}
    />
  );
};
