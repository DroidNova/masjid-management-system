import { Module } from '@nestjs/common';
import { PublicMasjidsController } from './public-masjids.controller';
import { PublicMasjidsService } from './public-masjids.service';

@Module({
  controllers: [PublicMasjidsController],
  providers: [PublicMasjidsService],
})
export class PublicMasjidsModule {}
